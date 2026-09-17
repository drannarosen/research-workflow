#!/usr/bin/env bash
# research-workflow repo consistency checks: version sync + hook/skill/command/agent/lens lint.
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
  if ! grep -q '^---$' <<<"$(head -1 "$f")"; then err "no frontmatter: $f"; continue; fi
  fm=$(awk 'NR>1 && /^---$/{exit} {print}' "$f")
  grep -q '^name:' <<<"$fm" || err "no name: in $f"
  grep -q '^description:' <<<"$fm" || err "no description: in $f"
  desc=$(sed -n '/^description:/{s/^description:[[:space:]]*//p;q;}' <<<"$fm")
  if grep -Eiq "Don.*t use|Do not use" <<<"$desc"; then
    ok "skill trigger partition: $nm"
  else
    err "no negative trigger partition in description: $f"
  fi
  if grep -q '^## Related' "$f"; then
    ok "skill related graph: $nm"
  else
    err "no ## Related block: $f"
  fi
  # Characters, not bytes: count UTF-32 code units (4 bytes each) so em-dashes and arrows count once.
  desc_len=$(( $(printf '%s' "$desc" | iconv -f UTF-8 -t UTF-32LE | wc -c | tr -d ' ') / 4 ))
  # The Agent Skills spec caps description at 1024 characters; past that the trigger text is cut.
  if [ "${desc_len:-0}" -gt 1024 ]; then
    err "description over 1024 chars ($desc_len): $f"
  elif [ "${desc_len:-0}" -gt 700 ]; then
    printf 'note  long description (%s chars): %s\n' "$desc_len" "$f"
  fi
  declared=$(printf '%s\n' "$fm" | awk -F': ' '/^name:/{print $2; exit}')
  if [ "$declared" = "$nm" ]; then ok "skill: $nm"; else err "skill name '$declared' != dir '$nm' ($f)"; fi
done

# 5) command frontmatter present (---, description:)
for f in commands/*.md; do
  [ -f "$f" ] || continue
  if grep -q '^---$' <<<"$(head -1 "$f")" && grep -q '^description:' "$f"; then ok "command: ${f##*/}"; else err "command frontmatter: $f"; fi
done

# 5b) agent frontmatter present (---, name:, description:, model:, tools:) and name matches file
if [ -d agents ]; then
  for f in agents/*.md; do
    [ -f "$f" ] || continue
    nm="${f##*/}"; nm="${nm%.md}"
    if ! grep -q '^---$' <<<"$(head -1 "$f")"; then err "no frontmatter: $f"; continue; fi
    fm=$(awk 'NR>1 && /^---$/{exit} {print}' "$f")
    grep -q '^name:' <<<"$fm" || err "no name: in $f"
    grep -q '^description:' <<<"$fm" || err "no description: in $f"
    grep -q '^model:' <<<"$fm" || err "no model: in $f"
    grep -q '^tools:' <<<"$fm" || err "no tools: in $f"
    declared=$(printf '%s\n' "$fm" | awk -F': ' '/^name:/{print $2; exit}')
    if [ "$declared" = "$nm" ]; then ok "agent: $nm"; else err "agent name '$declared' != file '$nm' ($f)"; fi
  done
fi

# 6) lenses referenced by skills exist — skipping lenses explicitly described as planned /
#    not-yet-shipping ("add when needed", "stub only", "on first ...").
while IFS= read -r line; do
  [ -n "$line" ] || continue
  f="${line%%:*}"
  grep -Eiq 'first need|first real|planned|stub only|TODO|on first|add .*when|when .*needs?' <<<"$line" && continue
  for lens in $(printf '%s' "$line" | grep -oE 'lenses/[A-Za-z0-9_-]+\.md'); do
    rel="${f%/*}/$lens"
    if [ -f "$rel" ]; then ok "lens present: $rel"; else err "lens missing: $rel (referenced in $f)"; fi
  done
done < <(grep -rnE 'lenses/[A-Za-z0-9_-]+\.md' skills/*/SKILL.md 2>/dev/null)

# 7) dangling cross-references (self-staleness): every "(→ target)" arrow-redirect must resolve to an
#    in-plugin skill or a known external. Catches links to removed/migrated skills — the failure that
#    bit us when a skill was dropped/migrated. Prefixed refs (plugin:skill) are assumed external/valid;
#    only hyphenated tokens are considered (skips prose words like "the"/"verify").
ext_allow="writing-science-voice grant-writing-voice quarto-expert clean-notebooks lecture-writing-astr101 lecture-writing writing-clearly-and-concisely elements-of-style superpowers"
skills_present=$(ls -1 skills)
dangling=0
while IFS= read -r tok; do
  [ -n "$tok" ] || continue
  grep -qx "$tok" <<<"$skills_present" && continue
  case " $ext_allow " in *" $tok "*) continue ;; esac
  err "dangling cross-ref: (→ $tok) resolves to no in-plugin skill or known external"
  dangling=1
done < <(grep -rhoE '\(→ `?[a-z][a-z0-9]*-[a-z0-9-]*' skills/*/SKILL.md 2>/dev/null | sed -E 's/.*\(→ `?//' | sort -u)
[ "$dangling" -eq 0 ] && ok "cross-references resolve (no dangling → redirects)"

# 7b) every `name` bullet in a skill's ## Related block resolves: an in-plugin skill, a namespaced
#     plugin:skill, a known external, or a bullet explicitly marked "(other plugin)". Catches Related
#     entries left pointing at merged/removed skills, which the arrow check (7) does not see.
related_bad=0
for f in skills/*/SKILL.md; do
  while IFS= read -r bullet; do
    tok=$(sed -n 's/^- `\([a-z][a-z0-9-]*\)`.*/\1/p' <<<"$bullet")
    [ -n "$tok" ] || continue
    grep -qx "$tok" <<<"$skills_present" && continue
    case " $ext_allow " in *" $tok "*) continue ;; esac
    grep -q '(other plugin)' <<<"$bullet" && continue
    err "unresolved Related entry: \`$tok\` in $f"
    related_bad=1
  done < <(awk '/^## Related/{r=1; next} r && /^## /{r=0} r && /^- `/' "$f")
done
[ "$related_bad" -eq 0 ] && ok "Related entries resolve"

# 8) staleness note (NON-fatal): date-stamped references decay; surface their age for human review.
#    Not a build failure — dates age with no code change; this is a visible reminder, not a gate.
while IFS= read -r line; do
  [ -n "$line" ] && printf 'note  staleness: %s\n' "$line"
done < <(grep -rnE 'updated:[[:space:]]*20[0-9]{2}-[0-9]{2}-[0-9]{2}|verified[[:space:]:]+20[0-9]{2}-[0-9]{2}-[0-9]{2}' skills/*/references/*.md 2>/dev/null)

# 9) shipped MyST plugins parse and pass injection/escaping fixtures.
if ls mystmd-plugins/*.mjs >/dev/null 2>&1; then
  if command -v node >/dev/null 2>&1; then
    for f in mystmd-plugins/*.mjs; do
      if node --check "$f" >/dev/null 2>&1; then
        ok "node syntax: $f"
      else
        err "node syntax: $f"
      fi
    done
    if [ -f scripts/check_interactive.mjs ]; then
      if node scripts/check_interactive.mjs >/dev/null 2>&1; then
        ok "interactive plugin fixtures"
      else
        err "interactive plugin fixtures"
      fi
    fi
  else
    err "node is required to validate mystmd-plugins/*.mjs"
  fi
fi

# 10) official Claude plugin validation when the Claude CLI is installed.
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate "$root" >/dev/null 2>&1; then
    ok "claude plugin validate"
  else
    err "claude plugin validate"
  fi
else
  printf 'note  claude CLI unavailable; skipping official plugin validation\n'
fi

# 11) shellcheck, with the same flags CI uses, so a local pass means a CI pass.
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -S error -e SC1091 "$root"/hooks/*.sh "$root"/scripts/*.sh >/dev/null 2>&1; then
    ok "shellcheck (CI flags)"
  else
    err "shellcheck (CI flags): run shellcheck -S error -e SC1091 hooks/*.sh scripts/*.sh"
  fi
else
  printf 'note  shellcheck unavailable; CI will still run it\n'
fi

if [ "$fail" -eq 0 ]; then echo "--- all checks passed ---"; else echo "--- checks FAILED ---"; fi
exit "$fail"
