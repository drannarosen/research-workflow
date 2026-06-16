#!/usr/bin/env bash
# research-workflow: SessionStart sanity check. Surfaces the one silent-total-failure mode —
# if jq is not on PATH, every other research-workflow hook fails open (no enforcement at all).
# Emits a warning via additionalContext so the agent flags it to the user. Silent when healthy.
# Must NOT itself depend on jq, and must tolerate a minimal PATH — so no external commands here.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
input=$(cat 2>/dev/null) || true   # drain the SessionStart payload (unused)

if command -v jq >/dev/null 2>&1; then
  rwf_log session "ok:jq-present"
  exit 0
fi

rwf_log session "warn:jq-missing"
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"⚠ research-workflow: jq is not on PATH, so the enforcement hooks (deletion, test-integrity, provenance, evidence-before-done) are INACTIVE — they fail open without jq. Tell the user to install jq (e.g. brew install jq) and restart Claude Code to re-enable the gates."}}'
exit 0
