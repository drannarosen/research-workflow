#!/usr/bin/env bash
# research-workflow HITL: hardcoded constants/coefficients need a source citation.
# Path-scoped: only fires on constants/coefficients/calibration files; inert elsewhere.
# Fail-open: parsing problems exit 0 (allow). On a missing-citation suspicion it asks, never hard-denies.
set -uo pipefail
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
case "$fp" in
  */imf/environment.py|*/defaults.py|*calibration*.py|*constants*.py|*coefficients*.py) ;;
  *) exit 0 ;;
esac
newc=$(printf '%s' "$input" | jq -r '[.tool_input.new_string, .tool_input.content, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0
# Does the edit introduce a float literal (a likely physical/empirical value)?
if printf '%s' "$newc" | grep -Eq '[-+]?[0-9]+\.[0-9]+([eE][-+]?[0-9]+)?'; then
  # ...without any visible citation token?
  if ! printf '%s' "$newc" | grep -Eiq '(doi|arxiv|bibcode|et al|table|eq\.|19[0-9]{2}|20[0-9]{2}|codata|iau)'; then
    printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow provenance gate: this edit to a constants/coefficients file adds numeric value(s) with no visible source citation (DOI/arXiv/ADS bibcode/Table/Eq./author-year). Add a provenance comment before shipping (see provenance-of-constants)."}'
  fi
fi
exit 0
