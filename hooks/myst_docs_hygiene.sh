#!/usr/bin/env bash
# research-workflow HITL: keep MyST (mystmd) docs to the house standard at edit time.
# PreToolUse(Edit/Write/MultiEdit). Self-limiting: only acts on `myst.yml` and on Markdown under a
# `docs/` path inside a MyST project (a myst.yml in the page's directory or up to 6 parents);
# everything else passes untouched. Catches the two mechanically-decidable sins that
# `myst build --strict` in CI is slow to surface or misses entirely:
#   1. legacy Sphinx-MyST syntax that mystmd silently does NOT support (renders empty / errors):
#      {toctree}, {eval-rst}, autodoc directives, raw RST `.. dir::`, sphinxcontrib/intersphinx;
#   2. a docs page (or its frontmatter) missing the house-minimum `title:` + `description:`.
# Page *voice/structure* rules are judgment, not regex -> they live in the myst plugin's
# docs-writing-voice skill, not here. Asks (never hard-denies); fails open on any error.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log myst-hygiene "allow:no-jq"; exit 0; }
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)

# A docs page belongs to a MyST project only if a myst.yml/myst.yaml sits in its directory or one of
# the 6 directories above it. Without this, every docs/*.md in any repo — a Sphinx project, a
# plan written to docs/plans/ — was held to mystmd rules it does not follow.
in_myst_project() { # file_path
  local d="${1%/*}"
  case "$1" in /*) ;; *) d="${cwd:-.}/$d" ;; esac
  for _ in 1 2 3 4 5 6 7; do
    if [ -f "$d/myst.yml" ] || [ -f "$d/myst.yaml" ]; then return 0; fi
    case "$d" in /|'') return 1 ;; esac
    d="${d%/*}"; [ -n "$d" ] || d="/"
  done
  return 1
}

kind=""
case "$fp" in
  */myst.yml|myst.yml|*/myst.yaml|myst.yaml) kind="yml" ;;
  *.md)
    case "$fp" in */docs/*|docs/*) kind="md" ;; *) ;; esac ;;
esac
[ -n "$kind" ] || { rwf_log myst-hygiene "allow:path-inert" "$fp"; exit 0; }
if [ "$kind" = "md" ] && ! in_myst_project "$fp"; then
  rwf_log myst-hygiene "allow:not-myst-project" "$fp"; exit 0
fi

newc=$(printf '%s' "$input" | jq -r '[.tool_input.new_string, .tool_input.content, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0
[ -n "$newc" ] || { rwf_log myst-hygiene "allow:no-content"; exit 0; }

ask() { # reason  message
  rwf_log myst-hygiene "ask:$1" "$fp"
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask"},"systemMessage":%s}\n' \
    "$(printf '%s' "research-workflow myst-docs-hygiene gate: $2 (see myst-expert / docs-writing-voice)." | jq -Rs .)"
  exit 0
}

if [ "$kind" = "yml" ]; then
  if grep -Eq 'myst_enable_extensions|sphinxcontrib|_toc\.yml|conf\.py' <<<"$newc"; then
    ask "legacy-yml" "this myst.yml uses legacy Sphinx config (myst_enable_extensions / sphinxcontrib / _toc.yml / conf.py). mystmd has no conf.py and enables math/deflists/GFM/footnotes by default; the table of contents lives under project.toc"
  fi
  rwf_log myst-hygiene "allow:clean" "$fp"; exit 0
fi

# kind = md (a Markdown file under docs/).
# 1) legacy / unsupported MyST syntax (these break in mystmd, not just discouraged).
if grep -Eq '\{(toctree|eval-rst|automodule|autoclass|autofunction|autosummary|autodoc|currentmodule|automodapi)\}|^[[:space:]]*\.\.[[:space:]]+[a-z][a-z-]*::|sphinxcontrib|intersphinx' <<<"$newc"; then
  ask "legacy-syntax" "this docs page uses legacy Sphinx-MyST syntax (toctree / eval-rst / autodoc / raw RST .. directive::) that mystmd does not support and renders empty or errors. Use the mystmd equivalent: an explicit project.toc in myst.yml, a script-generated API page, and [](#label) cross-references"
fi

# 2) house-minimum frontmatter (title + description). On Write of a new page, frontmatter must exist;
#    on any edit that rewrites the frontmatter block, that block must carry both keys. An Edit whose
#    text merely starts with `---` is a horizontal rule unless the text it replaces is itself a
#    frontmatter block (leading `---` plus a title:/description: key).
body=$(printf '%s\n' "$newc" | awk 'NF{p=1} p')          # drop leading blank lines
first_line=$(printf '%s\n' "$body" | head -n 1)
is_fm=0
if [ "$first_line" = "---" ]; then
  if [ "$tool" = "Write" ]; then
    is_fm=1
  else
    oldc=$(printf '%s' "$input" | jq -r '[.tool_input.old_string, (.tool_input.edits[]?.old_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null)
    old_first=$(printf '%s\n' "$oldc" | awk 'NF{print; exit}')
    if [ "$old_first" = "---" ] && grep -Eq '^[[:space:]]*(title|description):' <<<"$oldc"; then is_fm=1; fi
  fi
fi
if [ "$is_fm" -eq 1 ]; then
  fmblock=$(printf '%s\n' "$body" | awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}')
  has_title=$(printf '%s\n' "$fmblock" | grep -Ec '^[[:space:]]*title:[[:space:]]*[^[:space:]]')
  has_desc=$(printf '%s\n'  "$fmblock" | grep -Ec '^[[:space:]]*description:[[:space:]]*[^[:space:]]')
  if [ "$has_title" -eq 0 ] || [ "$has_desc" -eq 0 ]; then
    ask "frontmatter-incomplete" "this docs page frontmatter is missing the house minimum (needs both title: and description:)"
  fi
elif [ "$tool" = "Write" ]; then
  ask "frontmatter-missing" "this new docs page has no YAML frontmatter. Start it with a --- block carrying at least title: and description: (the house minimum for the docs ecosystem)"
fi

rwf_log myst-hygiene "allow:clean" "$fp"
exit 0
