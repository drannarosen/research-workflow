#!/usr/bin/env bash
# research-workflow HITL: hardcoded constants/coefficients need a source citation.
# Path-scoped: only fires on constants/coefficients/calibration files; inert elsewhere.
# Fail-open: parsing problems exit 0 (allow). On a missing-citation suspicion it asks, never hard-denies.
set -uo pipefail
__d=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
[ -n "${__d:-}" ] && [ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log provenance "allow:no-jq"; exit 0; }
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
newc=$(printf '%s' "$input" | jq -r '[.tool_input.new_string, .tool_input.content, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0

# (A) Data/input provenance (any file): a new reference to an external dataset/checkpoint — a
# data-file URL, or a path under raw/data/inputs/datasets/catalogs/checkpoints — should carry a
# source, version, and checksum. Relative output paths (e.g. "results.csv") don't match by design.
data_ext='(csv|tsv|h5|hdf5|nc|npz|npy|fits|parquet|feather|zarr|pkl|joblib|ckpt|pt|pth|onnx|dat)'
data_re="https?://[^[:space:]]+\.$data_ext|(^|[^[:alnum:]_])(raw|data|inputs?|datasets?|catalogs?|checkpoints?)/[^[:space:]]*\.$data_ext"
prov_re='sha-?(1|256)|md5|checksum|zenodo|doi|10\.[0-9]{4}/|bibcode|provenance|source[: ]|version|release|[ /]dr[0-9]'
if printf '%s' "$newc" | grep -Eiq "$data_re"; then
  if ! printf '%s' "$newc" | grep -Eiq "$prov_re"; then
    rwf_log provenance "ask:uncited-data" "$fp"
    printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow data-provenance gate: this edit references an external data file / checkpoint with no visible source, version, or checksum. Record where it came from (URL/DOI/Zenodo), its version or data-release, and a checksum before relying on it (see data-provenance)."}'
    exit 0
  fi
fi

# (B) Constants/coefficients provenance (path-scoped).
case "$fp" in
  */imf/environment.py|*/defaults.py|*calibration*.py|*constants*.py|*coefficients*.py) ;;
  *) rwf_log provenance "allow:path-inert" "$fp"; exit 0 ;;
esac
# Does the edit introduce a float literal (a likely physical/empirical value)?
if printf '%s' "$newc" | grep -Eq '[-+]?[0-9]+\.[0-9]+([eE][-+]?[0-9]+)?'; then
  # ...without any visible citation token?
  if ! printf '%s' "$newc" | grep -Eiq '(doi|arxiv|bibcode|et al|table|eq\.|19[0-9]{2}|20[0-9]{2}|codata|iau)'; then
    rwf_log provenance "ask:uncited-constant" "$fp"
    printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow provenance gate: this edit to a constants/coefficients file adds numeric value(s) with no visible source citation (DOI/arXiv/ADS bibcode/Table/Eq./author-year). Add a provenance comment before shipping (see provenance-of-constants)."}'
  else
    rwf_log provenance "allow:cited" "$fp"
  fi
else
  rwf_log provenance "allow:no-literal" "$fp"
fi
exit 0
