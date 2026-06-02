#!/usr/bin/env bash
# research-workflow HITL: confirm before destructive shell ops (rm / git rm / git clean / shred).
# Self-limiting: only reacts to destructive commands; everything else passes untouched.
# Fail-open: any parsing problem exits 0 (allow) so the gate never blocks legitimate work.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && exit 0
if printf '%s' "$cmd" | grep -Eiq '(^|[;&|(]|[[:space:]])rm([[:space:]]|$)|git[[:space:]]+rm([[:space:]]|$)|git[[:space:]]+clean|(^|[[:space:]])shred([[:space:]]|$)'; then
  printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow deletion gate: this command removes files. Confirm it is intended — and, for stale-code removal, that the item was inventoried and approved (see decision-log-and-commits)."}'
fi
exit 0
