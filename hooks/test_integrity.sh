#!/usr/bin/env bash
# research-workflow HITL: never weaken a test to make it pass.
# Path-scoped: only fires on test files; inert everywhere else (e.g. course work).
# Fail-open: parsing problems exit 0 (allow). On a suspected loosening it asks, never hard-denies.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
case "$fp" in
  *test_*.py|*_test.py|*/tests/*) ;;
  *) exit 0 ;;
esac
newc=$(printf '%s' "$input" | jq -r '[.tool_input.new_string, .tool_input.content, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0
oldc=$(printf '%s' "$input" | jq -r '[.tool_input.old_string, (.tool_input.edits[]?.old_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0
flags=""
printf '%s' "$newc" | grep -Eq '@pytest\.mark\.(skip|xfail)' && flags="adds skip/xfail"
oldn=$(printf '%s' "$oldc" | grep -c 'assert' 2>/dev/null || echo 0)
newn=$(printf '%s' "$newc" | grep -c 'assert' 2>/dev/null || echo 0)
{ [ "${oldn:-0}" -gt "${newn:-0}" ] 2>/dev/null; } && flags="${flags:+$flags; }removes assertion(s)"
ot=$(printf '%s' "$oldc" | grep -Eo '(rtol|atol)[[:space:]]*=[[:space:]]*[0-9.eE+-]+' | grep -Eo '[0-9.eE+-]+$' | sort -g | tail -1)
nt=$(printf '%s' "$newc" | grep -Eo '(rtol|atol)[[:space:]]*=[[:space:]]*[0-9.eE+-]+' | grep -Eo '[0-9.eE+-]+$' | sort -g | tail -1)
if [ -n "${ot:-}" ] && [ -n "${nt:-}" ]; then
  awk "BEGIN{exit !($nt > $ot)}" 2>/dev/null && flags="${flags:+$flags; }loosens a tolerance ($ot -> $nt)"
fi
if [ -n "$flags" ]; then
  printf '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow test-integrity gate: this test edit %s. Confirm you are NOT weakening a test to make it pass — fix the code/physics instead."}\n' "$flags"
fi
exit 0
