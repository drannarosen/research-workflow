#!/usr/bin/env bash
# research-workflow HITL: don't declare a task done while a stub is still in the code.
# Stop hook. Self-limiting: only blocks when the FINAL message claims COMPLETION
# (implemented / complete / done / ready) AND an Edit/Write THIS turn left a stub marker
# (NotImplementedError, TODO/FIXME/XXX/HACK/STUB, "placeholder", "not implemented") in a code file.
# Subagent-safe: exits 0 inside a subagent (.agent_id) so it never fires per-subagent; opt into
#   gating a subagent's claims with RWF_SUBAGENT_EVIDENCE (shared with the evidence gate).
# Fail-open: any parsing problem, missing transcript, or non-claim turn exits 0 (allow stop).
set -uo pipefail
__d=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
[ -n "${__d:-}" ] && [ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log no-stub "allow:no-jq"; exit 0; }
input=$(cat)

# Event + subagent handling — identical policy to the evidence gate (main-agent-only by default).
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null) || exit 0
agent_id=$(printf '%s' "$input" | jq -r '.agent_id // empty' 2>/dev/null) || exit 0
if [ "$event" = "SubagentStop" ]; then
  [ -n "${RWF_SUBAGENT_EVIDENCE:-}" ] || { rwf_log no-stub "allow:subagent-gate-off"; exit 0; }
else
  [ -n "$agent_id" ] && { rwf_log no-stub "allow:subagent" "$agent_id"; exit 0; }
fi

tp=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null) || exit 0

# Final assistant message: authoritative .last_assistant_message (race-free), transcript fallback
# only if absent. (See evidence_gate.sh for why the transcript tail lags at Stop-fire time.)
last=$(printf '%s' "$input" | jq -r '.last_assistant_message // empty' 2>/dev/null | tr '\n' ' ')
if [ -z "$last" ] && [ -n "$tp" ] && [ -r "$tp" ]; then
  last=$(jq -rc 'select(.type=="assistant") | (.message.content)
          | (if type=="array" then ([.[]|select(.type=="text")|.text]|join(" "))
             elif type=="string" then . else "" end)
          | gsub("\n";" ")' "$tp" 2>/dev/null | grep -v '^[[:space:]]*$' | tail -n 1)
fi
[ -n "$last" ] || { rwf_log no-stub "allow:empty-last"; exit 0; }

# Does the final message claim TASK COMPLETION? (Distinct from the evidence gate's test/result
# claims — this is "it's finished/implemented", the claim a leftover stub contradicts.)
claim_re='(implementation|feature|function|method|module|code|refactor|migration|everything|it|this)[[:space:]]+is[[:space:]]+(now[[:space:]]+)?(complete|done|finished|fully[[:space:]]+implemented|ready)|fully[[:space:]]+(implemented|functional|complete)|(implementation|feature|refactor|migration)[[:space:]]+(is[[:space:]]+)?(complete|done|finished)|ready[[:space:]]+(to|for)[[:space:]]+(use|review|merge|ship|production)|all[[:space:]]+(done|implemented|set|complete)|complete[[:space:]]+and[[:space:]]+(working|ready|tested)|no[[:space:]]+(more[[:space:]]+)?(stubs?|placeholders?|todos?)[[:space:]]+(left|remain)'
printf '%s' "$last" | grep -Eiq "$claim_re" || { rwf_log no-stub "allow:no-claim"; exit 0; }

# Did an Edit/Write THIS turn introduce a stub into a CODE file? Scan the recent transcript tail
# for Edit/Write/MultiEdit tool_use, emit "<file_path> :: <new content>" per call, then require
# BOTH a code-file extension AND a stub marker on the same record (so a stub word in a doc/markdown
# file, or a code edit with no stub, does not trip it).
[ -n "$tp" ] && [ -r "$tp" ] || { rwf_log no-stub "allow:claim-no-transcript"; exit 0; }
recent=$(tail -n 250 "$tp")
edits=$(printf '%s\n' "$recent" | jq -rc 'select(.type=="assistant") | (.message.content // [])
          | if type=="array" then (.[] | select(.type=="tool_use")
              | select(.name=="Edit" or .name=="Write" or .name=="MultiEdit")
              | ((.input.file_path // "") + " :: "
                 + (([.input.new_string, .input.content, (.input.edits[]?.new_string)]
                    | map(select(.!=null)) | join(" ")) | gsub("\n";" "))))
            else empty end' 2>/dev/null)
[ -n "$edits" ] || { rwf_log no-stub "allow:no-edits"; exit 0; }

codeline_re='\.(py|ipynb|js|jsx|ts|tsx|jl|c|h|cc|cpp|hpp|cu|f|f90|f95|rs|go|java|m|R|scala|kt)[[:space:]]*::'
stub_re='NotImplementedError|raise[[:space:]]+NotImplemented|(^|[^A-Za-z_])(TODO|FIXME|XXX|HACK|STUB|WIP)([^A-Za-z_]|$)|placeholder|not[[:space:]]+(yet[[:space:]]+)?implemented|to[[:space:]]+be[[:space:]]+implemented|implement[[:space:]]+(this|me|later)|stubbed[[:space:]]+out'
hit=$(printf '%s\n' "$edits" | grep -E "$codeline_re" | grep -Ei "$stub_re" | head -n 1)
if [ -z "$hit" ]; then rwf_log no-stub "allow:no-stub"; exit 0; fi

stub_file="${hit%% ::*}"
rwf_log no-stub "block:stub-when-done" "$stub_file"
printf '%s\n' '{"decision":"block","reason":"research-workflow no-stub-when-done gate: the final message claims the work is complete/implemented/ready, but an edit this turn left a stub in code (NotImplementedError, TODO/FIXME, a placeholder, or \"not implemented\"). Finish the stubbed code path, or — if it is genuinely out of scope — say so explicitly and restate what is and is not done, rather than claiming completion. See minimal-falsifiable-slice / evidence-first-execution."}'
exit 0
