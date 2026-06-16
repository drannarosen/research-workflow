#!/usr/bin/env bash
# research-workflow HITL: don't let a secret or credential file get committed.
# PreToolUse(Bash). Self-limiting: only reacts to `git add` / `git commit`; everything else passes.
# Two layers, both high-precision so it never nags on an ordinary commit:
#   A. the command string itself names a credential file (e.g. `git add .env`, `git add key.pem`);
#   B. the STAGED diff contains a secret signature (AWS/GitHub/Slack/Google token, a PRIVATE KEY
#      block, or a `api_key=…`-style assignment), or a credential file is staged — caught even when
#      it was swept in by `git add .`.
# Asks (never hard-denies); fails open on any error (no jq / not a repo / no git) so it never blocks.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log no-secrets-in-git "allow:no-jq"; exit 0; }
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -z "$cmd" ] && { rwf_log no-secrets-in-git "allow:no-cmd"; exit 0; }
# Only act on a git add / git commit (the moments content gets staged or recorded).
printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?(add|commit)([[:space:]]|$)' \
  || { rwf_log no-secrets-in-git "allow:not-git-add-commit"; exit 0; }

ask() {
  rwf_log no-secrets-in-git "ask:$1" "${2:-}"
  printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow no-secrets-in-git gate: this commit/add appears to include a secret or credential ('"$1"'). Secrets in git history are effectively permanent even after deletion. Remove it from the index (git rm --cached), move it out of the repo, and add it to .gitignore; commit a config template or load it from the environment instead. If this is a deliberate, non-sensitive fixture, proceed."}'
  exit 0
}

# Patterns. cred_path_re: filenames that should essentially never be committed.
cred_path_re='(^|[[:space:]/])\.(env|envrc)([[:space:]]|$|\.)|\.(pem|p12|pfx|pkcs12|key|keystore|jks)([[:space:]"'"'"']|$)|(^|[[:space:]/])id_rsa([[:space:]]|$)|\.netrc|\.htpasswd|(^|[[:space:]/])credentials([[:space:]]|$)|secrets?\.(ya?ml|json|env|txt|ini|cfg)'
# secret_re: high-entropy token signatures + a key=value assignment of a long secret-looking value.
secret_re='AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}|-----BEGIN[[:space:]][A-Z0-9 ]*PRIVATE KEY-----|xox[baprs]-[0-9A-Za-z-]{10,}|gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{20,}|(aws_secret_access_key|api[_-]?key|secret[_-]?key|access[_-]?token|client[_-]?secret|private[_-]?key)[[:space:]]*[:=][[:space:]]*[A-Za-z0-9/+_.=-]{16,}'

# Layer A: the command string explicitly names a credential file.
if printf '%s' "$cmd" | grep -Eiq "$cred_path_re"; then ask "credential-file-in-command"; fi

# Layer B: scan what is actually staged. Requires a usable repo; fail open otherwise.
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)
[ -n "$cwd" ] || cwd="."
git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1 || { rwf_log no-secrets-in-git "allow:not-a-repo"; exit 0; }

# `git commit -a/-am` also records tracked-but-unstaged modifications, so include the worktree diff
# in that case; otherwise only the index.
diff_args="--cached"
printf '%s' "$cmd" | grep -Eq 'commit[[:space:]][^|;&]*-[A-Za-z]*a' && diff_args=""

staged_names=$(git -C "$cwd" diff $diff_args --name-only 2>/dev/null)
if printf '%s' "$staged_names" | grep -Eiq "$cred_path_re"; then ask "credential-file-staged"; fi

staged_diff=$(git -C "$cwd" diff $diff_args 2>/dev/null)
if printf '%s' "$staged_diff" | grep -Eq "$secret_re"; then ask "secret-in-staged-diff"; fi

rwf_log no-secrets-in-git "allow:clean"
exit 0
