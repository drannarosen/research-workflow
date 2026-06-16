# shellcheck shell=bash
# research-workflow hooks — shared opt-in diagnostics.
# Sourced by each hook. Defines rwf_log(); a NO-OP unless RWF_HOOK_DEBUG is set, so it adds
# zero behaviour and ~no cost by default. When enabled it records, per turn, which hook fired
# and what it decided — the observability that was missing when a hook silently failed open.
#
# Enable:   export RWF_HOOK_DEBUG=1
# Logfile:  $RWF_HOOK_LOG  (default: ${TMPDIR:-/tmp}/research-workflow-hooks.log)
# Read it:  tail -f "${RWF_HOOK_LOG:-${TMPDIR:-/tmp}/research-workflow-hooks.log}"
#
# Usage:    rwf_log <hook-name> <decision> [detail...]
#   decision convention: "allow:<why>" | "ask:<why>" | "block:<why>"
# Uses only printf/date (no jq), so it works even when the jq-missing fail-open path is hit.
rwf_log() {
  [ -n "${RWF_HOOK_DEBUG:-}" ] || return 0
  local logf="${RWF_HOOK_LOG:-${TMPDIR:-/tmp}/research-workflow-hooks.log}"
  local hook="${1:-?}" decision="${2:-?}"; shift 2 2>/dev/null || true
  printf '%s [%s] %s%s\n' \
    "$(date '+%Y-%m-%dT%H:%M:%S' 2>/dev/null)" "$hook" "$decision" "${*:+ — $*}" \
    >>"$logf" 2>/dev/null || true
}
