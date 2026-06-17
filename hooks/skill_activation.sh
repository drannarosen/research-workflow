#!/usr/bin/env bash
# research-workflow observability: log which skills actually get invoked.
# PreToolUse(Skill). Never blocks — it only records, so the firing-data review (RWF_HOOK_DEBUG)
# covers the advisory layer (48 skills) and not just the 8 deterministic hooks. This is the
# discriminator the suite was missing: a skill that never appears in the log never fired.
# Silent and zero-cost unless RWF_HOOK_DEBUG is set (rwf_log is a no-op otherwise). Fails open.
#
# NOTE / honest limitation: this captures skills invoked through the Skill TOOL (the explicit
# "I'm using X" path). If the model silently follows a skill's surfaced description without
# invoking the tool, that is not logged — no deterministic signal exists for that. So this is a
# lower bound on skill use, not a complete census.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
skill=$(printf '%s' "$input" | jq -r '.tool_input.skill // .tool_input.name // .tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$skill" ] && rwf_log skill "invoke:$skill"
exit 0
