#!/usr/bin/env bash
# research-workflow repo consistency checks: version sync + hook/skill/command/lens lint.
# Run locally (`bash scripts/checks.sh`) or in CI. Exits non-zero on any failure.
set -uo pipefail
root="$(cd "${0%/*}/.." && pwd)" || exit 2
cd "$root" || exit 2
command -v jq >/dev/null 2>&1 || { echo "checks: jq is required"; exit 2; }

fail=0
err() { printf 'FAIL  %s\n' "$1"; fail=1; }
ok()  { printf 'ok    %s\n' "$1"; }

# 1) plugin.json <-> marketplace.json version sync (the deployment-drift guard)
pv=$(jq -r '.version // empty' .claude-plugin/plugin.json)
mv=$(jq -r '(.plugins[]? | select(.name=="research-workflow") | .version) // empty' .claude-plugin/marketplace.json)
if [ -n "$pv" ] && [ "$pv" = "$mv" ]; then ok "version sync ($pv)"; else err "version mismatch: plugin.json=$pv marketplace.json=$mv"; fi

# 2) hooks.json parses, and every ${CLAUDE_PLUGIN_ROOT}-referenced file exists
if jq empty hooks/hooks.json 2>/dev/null; then ok "hooks.json parses"; else err "hooks.json invalid JSON"; fi
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  if [ -f "$rel" ]; then ok "referenced file present: $rel"; else err "referenced file missing: $rel"; fi
done < <(grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/[A-Za-z0-9_./-]+' hooks/hooks.json | sed 's#[$]{CLAUDE_PLUGIN_ROOT}/##' | sort -u)

# 3) every hook script is syntactically valid bash
for h in hooks/*.sh; do
  if bash -n "$h" 2>/dev/null; then ok "syntax: $h"; else err "syntax error: $h"; fi
done

# 4) skill frontmatter present (---, name:, description:) and name matches directory
for d in skills/*/; do
  nm="${d%/}"; nm="${nm##*/}"; f="${d}SKILL.md"
  if [ ! -f "$f" ]; then err "no SKILL.md in $d"; continue; fi
  if ! head -1 "$f" | grep -q '^---$'; then err "no frontmatter: $f"; continue; fi
  fm=$(awk 'NR>1 && /^---$/{exit} {print}' "$f")
  printf '%s\n' "$fm" | grep -q '^name:' || err "no name: in $f"
  printf '%s\n' "$fm" | grep -q '^description:' || err "no description: in $f"
  declared=$(printf '%s\n' "$fm" | awk -F': ' '/^name:/{print $2; exit}')
  if [ "$declared" = "$nm" ]; then ok "skill: $nm"; else err "skill name '$declared' != dir '$nm' ($f)"; fi
done

# 5) command frontmatter present (---, description:)
for f in commands/*.md; do
  [ -f "$f" ] || continue
  if head -1 "$f" | grep -q '^---$' && grep -q '^description:' "$f"; then ok "command: ${f##*/}"; else err "command frontmatter: $f"; fi
done

# 6) lenses referenced by skills exist — skipping lenses explicitly described as planned /
#    not-yet-shipping ("add when needed", "stub only", "on first ...").
while IFS= read -r line; do
  [ -n "$line" ] || continue
  f="${line%%:*}"
  printf '%s' "$line" | grep -Eiq 'first need|first real|planned|stub only|TODO|on first|add .*when|when .*needs?' && continue
  for lens in $(printf '%s' "$line" | grep -oE 'lenses/[A-Za-z0-9_-]+\.md'); do
    rel="${f%/*}/$lens"
    if [ -f "$rel" ]; then ok "lens present: $rel"; else err "lens missing: $rel (referenced in $f)"; fi
  done
done < <(grep -rnE 'lenses/[A-Za-z0-9_-]+\.md' skills/*/SKILL.md 2>/dev/null)

# 7) dangling cross-references (self-staleness): every "(→ target)" arrow-redirect must resolve to an
#    in-plugin skill or a known external. Catches links to removed/migrated skills — the failure that
#    bit us when a skill was dropped/migrated. Prefixed refs (plugin:skill) are assumed external/valid;
#    only hyphenated tokens are considered (skips prose words like "the"/"verify").
ext_allow="brain-frontend page-beautifier writing-science-voice grant-writing-voice quarto-expert clean-notebooks lecture-writing-astr101 lecture-writing writing-clearly-and-concisely elements-of-style superpowers"
skills_present=$(ls -1 skills)
dangling=0
while IFS= read -r tok; do
  [ -n "$tok" ] || continue
  printf '%s\n' "$skills_present" | grep -qx "$tok" && continue
  case " $ext_allow " in *" $tok "*) continue ;; esac
  err "dangling cross-ref: (→ $tok) resolves to no in-plugin skill or known external"
  dangling=1
done < <(grep -rhoE '\(→ `?[a-z][a-z0-9]*-[a-z0-9-]*' skills/*/SKILL.md 2>/dev/null | sed -E 's/.*\(→ `?//' | sort -u)
[ "$dangling" -eq 0 ] && ok "cross-references resolve (no dangling → redirects)"

# 8) staleness note (NON-fatal): date-stamped references decay; surface their age for human review.
#    Not a build failure — dates age with no code change; this is a visible reminder, not a gate.
while IFS= read -r line; do
  [ -n "$line" ] && printf 'note  staleness: %s\n' "$line"
done < <(grep -rnE 'updated:[[:space:]]*20[0-9]{2}-[0-9]{2}-[0-9]{2}|verified[[:space:]:]+20[0-9]{2}-[0-9]{2}-[0-9]{2}' skills/*/references/*.md 2>/dev/null)

if [ "$fail" -eq 0 ]; then echo "--- all checks passed ---"; else echo "--- checks FAILED ---"; fi
exit "$fail"
