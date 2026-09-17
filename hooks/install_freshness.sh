#!/usr/bin/env bash
# research-workflow: SessionStart freshness check for DEVELOPMENT installs from a local directory
# marketplace. The plugin cache is keyed by version, and this plugin's version is pinned while
# unreleased, so `claude plugin update` never refreshes it — the installed copy once sat three months
# behind the repo. If the installed skills/hooks/commands/agents/manifest differ from the source
# directory, emit a warning with the reinstall command. Never blocks.
# Silent when: no CLAUDE_PLUGIN_ROOT, no jq, no directory-marketplace entry, source missing, or equal.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
cat >/dev/null 2>&1 || true   # drain the SessionStart payload (unused)

root="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$root" ] && [ -d "$root" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
known="${RWF_KNOWN_MARKETPLACES:-$HOME/.claude/plugins/known_marketplaces.json}"
[ -r "$known" ] || exit 0

# Cache layout: .../cache/<marketplace>/<plugin>/<version>
version_dir="${root%/}"; plugin_dir="${version_dir%/*}"; market_dir="${plugin_dir%/*}"
plugin="${plugin_dir##*/}"; market="${market_dir##*/}"
src=$(jq -r --arg m "$market" '.[$m] | select(.source.source=="directory") | (.installLocation // .source.path) // empty' "$known" 2>/dev/null)
[ -n "$src" ] && [ -d "$src" ] || { rwf_log freshness "skip:no-directory-source"; exit 0; }

fingerprint() { # dir -> one hash over relative paths + contents of the shipped trees
  ( cd "$1" 2>/dev/null || exit 0
    find skills hooks commands agents .claude-plugin -type f \
      ! -name '.DS_Store' ! -name '*.log' ! -path '*/__pycache__/*' ! -path '*/.mypy_cache/*' \
      ! -path '*/.pytest_cache/*' ! -path '*/.ruff_cache/*' 2>/dev/null \
      | LC_ALL=C sort | while IFS= read -r f; do printf '%s  ' "$f"; shasum < "$f"; done | shasum )
}
[ "$(fingerprint "$root")" = "$(fingerprint "$src")" ] && { rwf_log freshness "ok:fresh"; exit 0; }

rwf_log freshness "warn:stale-install" "$src"
msg="⚠ research-workflow: the installed plugin ($root) differs from its source repo ($src), so this session is running an older copy of the skills/hooks. Because the version is pinned, 'claude plugin update' will not refresh it. Tell the user to reinstall: claude plugin uninstall ${plugin}@${market} --keep-data && claude plugin install ${plugin}@${market}, then restart Claude Code."
jq -nc --arg m "$msg" '{hookSpecificOutput:{hookEventName:"SessionStart",additionalContext:$m}}'
exit 0
