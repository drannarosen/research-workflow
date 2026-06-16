#!/usr/bin/env bash
# research-workflow HITL: don't claim "fixed / passing / converged / built" without fresh evidence.
# Stop hook. Self-limiting: only blocks when the FINAL message makes a code/test/result claim
# AND the current turn shows no supporting command execution.
# Subagent-safe: exits 0 immediately inside a subagent (.agent_id present) so it never fires
#   per-subagent in subagent-driven workflows — only the main agent's final Stop is gated.
# Fail-open: any parsing problem, missing transcript, or non-claim turn exits 0 (allow stop).
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)

# Inside a subagent, the Stop input carries .agent_id. Delegated work verifies itself; the
# main agent's final Stop is the only place we demand evidence. -> allow and get out.
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null) || exit 0
[ -n "$agent_id" ] && exit 0

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
[ -n "$last" ] || exit 0

# Does the final message assert a CODE / TEST / RESULT / BUILD outcome? (Not generic "done".)
claim_re='tests?[[:space:]]+(pass|passed|passing|are[[:space:]]+green)|all[[:space:]]+tests[[:space:]]+pass|((the[[:space:]]+)?bug[[:space:]]+is[[:space:]]+fixed)|(is[[:space:]]+now[[:space:]]+fixed)|(it[[:space:]]+|has[[:space:]]+|have[[:space:]]+)?converged|[0-9.]+[[:space:]]*%[[:space:]]*(accuracy|error|relative)|build[[:space:]]+(succeed|succeeds|succeeded|passes|passed|is[[:space:]]+green)|compiles?[[:space:]]+(clean|cleanly|now|without)|passes?[[:space:]]+now'
printf '%s' "$last" | grep -Eiq "$claim_re" || exit 0

# Evidence from the recent tail: tool executions (Bash/Task/...) and their results. These ARE
# flushed to the transcript as they happen during the turn, so the tail is reliable for them.
[ -n "$tp" ] && [ -r "$tp" ] || exit 0
recent=$(tail -n 250 "$tp")
tools=$(printf '%s\n' "$recent" | jq -rc 'select(.type=="assistant") | (.message.content // [])
          | if type=="array" then (.[] | select(.type=="tool_use")
              | (.name + " :: " + ((.input.command // .input.description // .input.file_path // "")|tostring)))
            else empty end' 2>/dev/null)
results=$(printf '%s\n' "$recent" | jq -rc 'select(.type=="user") | (.message.content // [])
          | if type=="array" then (.[] | select(.type=="tool_result")
              | (.content | if type=="array" then ([.[]?.text]|join(" ")) else tostring end))
            else empty end' 2>/dev/null)

# A verification ran (or was delegated to a subagent via Task) -> evidence present, allow.
evid_re='pytest|py\.test|unittest|[0-9]+[[:space:]]+passed|[[:space:]]passed[,.[:space:]]|PASSED|=+[[:space:]].*test[[:space:]]+session|cargo[[:space:]]+(test|build)|go[[:space:]]+test|npm[[:space:]]+(test|run)|(^|[[:space:]])make([[:space:]]|$)|tox|nox|conftest|Task[[:space:]]+::|validate|verify|convergen|order.?of.?accuracy|grad.?check'
if printf '%s\n%s' "$tools" "$results" | grep -Eiq "$evid_re"; then
  exit 0
fi

# Claim made, no fresh supporting output in this turn -> block the stop.
printf '%s\n' '{"decision":"block","reason":"research-workflow evidence-before-done gate: the final message claims a code/test/result/build outcome (fixed / passing / converged / built) but this turn shows no fresh supporting command output. Run the verification appropriate to the work (pytest / a validation script / a build) and show its output, then conclude — or, if this was a planning/design turn, restate without the outcome claim. See evidence-first-execution / verification-gate."}'
exit 0
