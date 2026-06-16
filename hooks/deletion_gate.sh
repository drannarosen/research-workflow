#!/usr/bin/env bash
# research-workflow HITL: confirm before destructive shell ops (rm / git rm / git clean / shred).
# Self-limiting: only reacts to destructive commands; everything else passes untouched.
# Fail-open: any parsing problem exits 0 (allow) so the gate never blocks legitimate work.
set -uo pipefail
__d=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
[ -n "${__d:-}" ] && [ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log deletion "allow:no-jq"; exit 0; }
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && { rwf_log deletion "allow:no-cmd"; exit 0; }
if printf '%s' "$cmd" | grep -Eiq '(^|[;&|(]|[[:space:]])rm([[:space:]]|$)|git[[:space:]]+rm([[:space:]]|$)|git[[:space:]]+clean|(^|[[:space:]])shred([[:space:]]|$)'; then
  rwf_log deletion "ask:destructive" "$cmd"
  printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow deletion gate: this command removes files. Confirm it is intended — and, for stale-code removal, that the item was inventoried and approved (see decision-log-and-commits)."}'
else
  rwf_log deletion "allow:not-destructive"
fi
exit 0
