#!/usr/bin/env bash
# research-workflow HITL: don't claim "fixed / passing / converged / built" without fresh evidence.
# Stop hook. Self-limiting: only blocks when the FINAL message makes a code/test/result claim
# AND the current turn shows no supporting command execution.
# Subagent-safe: exits 0 immediately inside a subagent (.agent_id present) so it never fires
#   per-subagent in subagent-driven workflows — only the main agent's final Stop is gated.
# Fail-open: any parsing problem, missing transcript, or non-claim turn exits 0 (allow stop).
set -uo pipefail
__d=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
[ -n "${__d:-}" ] && [ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log evidence "allow:no-jq"; exit 0; }
input=$(cat)

# Event + subagent handling. By default the gate is MAIN-AGENT ONLY: a subagent's Stop carries
# .agent_id and delegated work verifies itself, so it is exempt. Opt in to also gating a
# subagent's final claims by setting RWF_SUBAGENT_EVIDENCE — then the SubagentStop event is
# gated with the same claim/evidence logic. (No hook_event_name -> older Claude Code -> treat
# as main Stop, preserving prior behaviour.)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null) || exit 0
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null) || exit 0
if [ "$event" = "SubagentStop" ]; then
  [ -n "${RWF_SUBAGENT_EVIDENCE:-}" ] || { rwf_log evidence "allow:subagent-gate-off"; exit 0; }
else
  [ -n "$agent_id" ] && { rwf_log evidence "allow:subagent" "$agent_id"; exit 0; }
fi

tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null) || exit 0

# The final assistant message this Stop is gating. Claude Code passes it directly in the hook
# input as .last_assistant_message — authoritative and race-free. Do NOT parse the transcript
# tail for it: at Stop-hook fire time the just-finished message is typically not yet flushed to
# the transcript file, so `tail` returns the PREVIOUS turn's message and the gate checks the
# wrong text (it then never blocks). Fall back to the transcript only if the field is absent
# (older Claude Code that doesn't supply it).
last=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | tr '\n' ' ')
if [ -z "$last" ] && [ -n "$tp" ] && [ -r "$tp" ]; then
  last=$(jq -rc 'select(.type=="assistant") | (.message.content)
          | (if type=="array" then ([.[]|select(.type=="text")|.text]|join(" "))
             elif type=="string" then . else "" end)
          | gsub("\n";" ")' "$tp" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -n 1)
fi
[ -n "$last" ] || { rwf_log evidence "allow:empty-last"; exit 0; }

# Does the final message assert a CODE / TEST / RESULT / BUILD outcome? (Not generic "done".)
claim_re='tests?[[:space:]]+(pass|passed|passing|are[[:space:]]+green)|all[[:space:]]+tests[[:space:]]+pass|((the[[:space:]]+)?bug[[:space:]]+is[[:space:]]+fixed)|(is[[:space:]]+now[[:space:]]+fixed)|(it[[:space:]]+|has[[:space:]]+|have[[:space:]]+)?converged|[0-9.]+[[:space:]]*%[[:space:]]*(accuracy|error|relative)|build[[:space:]]+(succeed|succeeds|succeeded|passes|passed|is[[:space:]]+green)|compiles?[[:space:]]+(clean|cleanly|now|without)|passes?[[:space:]]+now'
printf '%s' "$last" | grep -Eiq "$claim_re" || { rwf_log evidence "allow:no-claim"; exit 0; }

# Evidence that a verification actually RAN this turn. Flushed to the transcript as it happens,
# so the tail is reliable. Two deliberately narrow signals — scoped this way so that merely
# READING or displaying a file (a test file, or this gate's own source, which contain words
# like "pytest"/"verify"/"PASSED") is NOT mistaken for a verification having run:
#   1. an executed COMMAND (Bash .input.command) that invokes a known runner, or work
#      delegated to a subagent (Task) — we scan command strings only, never tool-result
#      bodies or file paths (Read/Edit/Write file_path is excluded);
#   2. a tool RESULT showing a genuine NUMERIC/structured pass-summary (e.g. "16 passed"),
#      chosen so prose or source mentioning "verify"/"passed" in passing does not trip it.
[ -n "$tp" ] && [ -r "$tp" ] || { rwf_log evidence "allow:claim-no-transcript"; exit 0; }
recent=$(tail -n 250 "$tp")
cmds=$(printf '%s\n' "$recent" | jq -rc 'select(.type=="assistant") | (.message.content // [])
          | if type=="array" then (.[] | select(.type=="tool_use")
              | select(.name=="Bash" or .name=="Task")
              | (.name + " :: " + ((.input.command // .input.description // .input.prompt // "")|tostring)))
            else empty end' 2>/dev/null)
results=$(printf '%s\n' "$recent" | jq -rc 'select(.type=="user") | (.message.content // [])
          | if type=="array" then (.[] | select(.type=="tool_result")
              | (.content | if type=="array" then ([.[]?.text]|join(" ")) else tostring end))
            else empty end' 2>/dev/null)

# (1) A verification command ran, or work was delegated to a subagent. "validate/verify/check/
#     convergen/grad-check" count only in executed-command context (a script being run), not as
#     bare words in prose/results.
run_re='pytest|py\.test|unittest|(cargo|go|npm|pnpm|yarn)[[:space:]]+(test|build|run)|(^|[[:space:]])make([[:space:]]|$)|tox|nox|ctest|run_tests|(validate|verify|check|benchmark|convergen)[a-z_]*\.(sh|py)|(python[0-9.]*|uv[[:space:]]+run|pixi[[:space:]]+run|\./)[^|;&]*\b(validate|verify|test|check|convergen|grad.?check|order.?of.?accuracy)|Task[[:space:]]*::'
if printf '%s' "$cmds" | grep -Eiq "$run_re"; then
  rwf_log evidence "allow:ran-verification"
  exit 0
fi
# (2) A tool result shows a real test-runner pass summary.
pass_re='[0-9]+[[:space:]]+(passed|failed|error)|[0-9]+[[:space:]]+(tests?|examples?|checks?|assertions?|cases?)[[:space:]]+(ran|passed|ok|complete)|=+[[:space:]]*[0-9].*passed|test[[:space:]]+session[[:space:]]+starts|OK[[:space:]]*\([0-9]'
if printf '%s' "$results" | grep -Eiq "$pass_re"; then
  rwf_log evidence "allow:pass-summary"
  exit 0
fi

# Claim made, no fresh supporting output in this turn -> block the stop.
rwf_log evidence "block:claim-without-evidence" "$last"
printf '%s\n' '{"decision":"block","reason":"research-workflow evidence-before-done gate: the final message claims a code/test/result/build outcome (fixed / passing / converged / built) but this turn shows no fresh supporting command output. Run the verification appropriate to the work (pytest / a validation script / a build) and show its output, then conclude — or, if this was a planning/design turn, restate without the outcome claim. See evidence-first-execution / verification-gate."}'
exit 0
