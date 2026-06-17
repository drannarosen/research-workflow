#!/usr/bin/env bash
# Smoke tests for the research-workflow enforcement hooks.
#   Run: bash hooks/tests/run_tests.sh
# Feeds representative tool-call JSON to each hook and checks whether it asks
# (emits a permissionDecision) or stays silent (allows). Uses printf so JSON
# escapes like \n remain literal -> valid JSON (zsh `echo` would corrupt them).
set -uo pipefail
HOOKS="$(cd "$(dirname "$0")/.." && pwd)"
pass=0; fail=0

check() { # name  expected(ask|empty)  actual-output
  local name="$1" exp="$2" out="$3" got="empty"
  [ -n "$out" ] && got="ask"
  if [ "$got" = "$exp" ]; then printf 'PASS: %-34s (%s)\n' "$name" "$got"; pass=$((pass+1))
  else printf 'FAIL: %-34s (expected %s, got %s)\n' "$name" "$exp" "$got"; fail=$((fail+1)); fi
}
run() { printf '%s' "$2" | bash "$HOOKS/$1"; }

# evidence_gate.sh is a Stop hook: it reads .transcript_path (a JSONL file) and
# .agent_id, not .tool_input. These helpers build transcript fixtures + Stop input.
TMPD=$(mktemp -d)
trap 'rm -rf "$TMPD"' EXIT
mktr()   { local f="$TMPD/$1"; shift; printf '%s\n' "$@" > "$f"; printf '%s' "$f"; }
stopin() { # transcript_path  [agent_id]
  if [ -n "${2:-}" ]; then printf '{"hook_event_name":"Stop","transcript_path":"%s","agent_id":"%s","agent_type":"Explore"}' "$1" "$2"
  else printf '{"hook_event_name":"Stop","transcript_path":"%s"}' "$1"; fi
}

check "deletion: rm -rf"            ask   "$(run deletion_gate.sh '{"tool_input":{"command":"rm -rf build"}}')"
check "deletion: git rm"            ask   "$(run deletion_gate.sh '{"tool_input":{"command":"git rm old.py"}}')"
check "deletion: benign ls"         empty "$(run deletion_gate.sh '{"tool_input":{"command":"ls -la && cat README.md"}}')"
check "test: loosen rtol 0.05->0.5" ask   "$(run test_integrity.sh '{"tool_input":{"file_path":"tests/test_x.py","old_string":"rtol=0.05","new_string":"rtol=0.5"}}')"
check "test: add skip"              ask   "$(run test_integrity.sh '{"tool_input":{"file_path":"tests/test_x.py","new_string":"@pytest.mark.skip\ndef test_z():\n    pass"}}')"
check "test: tighten rtol (ok)"     empty "$(run test_integrity.sh '{"tool_input":{"file_path":"tests/test_x.py","old_string":"rtol=0.5","new_string":"rtol=0.05"}}')"
check "test: non-test file"         empty "$(run test_integrity.sh '{"tool_input":{"file_path":"src/foo.py","new_string":"rtol=0.9"}}')"
check "prov: bare constant"         ask   "$(run provenance.sh '{"tool_input":{"file_path":"pkg/constants.py","new_string":"eta = 0.1"}}')"
check "prov: cited constant"        empty "$(run provenance.sh '{"tool_input":{"file_path":"pkg/constants.py","new_string":"eta = 0.1  # Frank, King & Raine 2002"}}')"
check "prov: non-constants file"    empty "$(run provenance.sh '{"tool_input":{"file_path":"src/foo.py","new_string":"x = 0.1"}}')"
check "data: uncited dataset URL"   ask   "$(run provenance.sh '{"tool_input":{"file_path":"src/load.py","new_string":"cat = fetch(\"https://example.com/gaia.fits\")"}}')"
check "data: cited dataset (zenodo)" empty "$(run provenance.sh '{"tool_input":{"file_path":"src/load.py","new_string":"# Zenodo DOI 10.5281/zenodo.7, sha256 abc\nckpt = load(\"https://zenodo.org/record/7/files/model.ckpt\")"}}')"
check "data: output csv not flagged" empty "$(run provenance.sh '{"tool_input":{"file_path":"src/run.py","new_string":"df.to_csv(\"results.csv\")"}}')"
check "data: data/raw path uncited" ask   "$(run provenance.sh '{"tool_input":{"file_path":"src/load.py","new_string":"path = \"data/raw/spectra.npz\""}}')"
check "silent-except: inline pass"  ask   "$(run no_silent_except.sh '{"tool_input":{"file_path":"a.py","new_string":"try:\n    f()\nexcept Exception: pass"}}')"
check "silent-except: bare except"  ask   "$(run no_silent_except.sh '{"tool_input":{"file_path":"a.py","new_string":"try:\n    f()\nexcept:\n    handle()"}}')"
check "silent-except: block pass"   ask   "$(run no_silent_except.sh '{"tool_input":{"file_path":"a.py","new_string":"try:\n    f()\nexcept ValueError:\n    pass"}}')"
check "silent-except: handled ok"   empty "$(run no_silent_except.sh '{"tool_input":{"file_path":"a.py","new_string":"try:\n    f()\nexcept ValueError as e:\n    log(e)\n    raise"}}')"
check "silent-except: comment only" empty "$(run no_silent_except.sh '{"tool_input":{"file_path":"a.py","new_string":"# except: pass is bad\nx = 1"}}')"
check "silent-except: non-python"   empty "$(run no_silent_except.sh '{"tool_input":{"file_path":"notes.md","new_string":"except: pass"}}')"

# --- no-secrets-in-git (command-string layer; cwd outside any repo so only layer A acts) ---
NONREPO="$TMPD/notrepo"; mkdir -p "$NONREPO"
secin() { printf '{"tool_input":{"command":"%s"},"cwd":"%s"}' "$1" "$NONREPO"; }
check "secrets: git add .env"        ask   "$(run no_secrets_in_git.sh "$(secin "git add .env")")"
check "secrets: git add key.pem"     ask   "$(run no_secrets_in_git.sh "$(secin "git add deploy.pem")")"
check "secrets: git status (no-op)"  empty "$(run no_secrets_in_git.sh "$(secin "git status")")"
check "secrets: git add normal file" empty "$(run no_secrets_in_git.sh "$(secin "git add src/foo.py")")"

# --- myst-docs-hygiene (docs/*.md + myst.yml legacy-syntax / frontmatter gate) ---
check "myst: legacy toctree in docs"  ask   "$(run myst_docs_hygiene.sh '{"tool_name":"Write","tool_input":{"file_path":"p/docs/x.md","content":"---\ntitle: X\ndescription: y\n---\n```{toctree}\n```"}}')"
check "myst: clean docs page"          empty "$(run myst_docs_hygiene.sh '{"tool_name":"Write","tool_input":{"file_path":"p/docs/x.md","content":"---\ntitle: X\ndescription: y\n---\n# X"}}')"
check "myst: new page no frontmatter"  ask   "$(run myst_docs_hygiene.sh '{"tool_name":"Write","tool_input":{"file_path":"p/docs/x.md","content":"# X\nbody"}}')"
check "myst: frontmatter no desc"      ask   "$(run myst_docs_hygiene.sh '{"tool_name":"Write","tool_input":{"file_path":"p/docs/x.md","content":"---\ntitle: X\n---\n# X"}}')"
check "myst: non-docs md inert"        empty "$(run myst_docs_hygiene.sh '{"tool_name":"Write","tool_input":{"file_path":"README.md","content":"# readme\nno frontmatter here"}}')"
check "myst: partial edit, no fm"      empty "$(run myst_docs_hygiene.sh '{"tool_name":"Edit","tool_input":{"file_path":"p/docs/x.md","new_string":"a normal added paragraph."}}')"
check "myst: legacy myst.yml"          ask   "$(run myst_docs_hygiene.sh '{"tool_name":"Edit","tool_input":{"file_path":"p/myst.yml","new_string":"myst_enable_extensions: [dollarmath]"}}')"
check "myst: clean myst.yml"           empty "$(run myst_docs_hygiene.sh '{"tool_name":"Edit","tool_input":{"file_path":"p/myst.yml","new_string":"project:\n  toc:\n    - file: index.md"}}')"

# --- skill-activation logging (never blocks; logs the invoked skill under RWF_HOOK_DEBUG) ---
check "skill-activation: never blocks"  empty "$(run skill_activation.sh '{"tool_input":{"skill":"research-workflow:numerical-precision"}}')"

# --- evidence-before-done Stop gate ---
TR_CLAIM=$(mktr claim.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix the bug"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The bug is fixed and all tests pass."}]}}')
TR_EVID=$(mktr evid.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix the bug"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"pytest -q"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"3 passed in 0.4s"}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"All tests pass now."}]}}')
TR_TASK=$(mktr task.jsonl \
  '{"type":"user","message":{"role":"user","content":"implement X"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Task","input":{"description":"implement and test X"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"Implemented X; ran pytest, 5 passed."}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Done — the subagent implemented X and tests pass."}]}}')
TR_DESIGN=$(mktr design.jsonl \
  '{"type":"user","message":{"role":"user","content":"what is the root cause?"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Here are two fix strategies; which do you prefer?"}]}}')

# Weakness fixtures: reading/displaying text that merely CONTAINS verification words must
# NOT count as evidence (only actually RUNNING a verifier does).
TR_CONTAM=$(mktr contam.jsonl \
  '{"type":"user","message":{"role":"user","content":"is the gate ok?"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"hooks/evidence_gate.sh"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"evid_re includes pytest unittest validate verify convergen PASSED conftest"}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The gate works and all tests pass."}]}}')
TR_OVERBROAD=$(mktr overbroad.jsonl \
  '{"type":"user","message":{"role":"user","content":"what does foo.py do?"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"src/foo.py"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"def f(x):  # verify and validate inputs before use\n    return x"}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Looks right — the bug is fixed."}]}}')
# A real run whose runner name is non-obvious but whose RESULT shows a numeric pass summary.
TR_CISH=$(mktr cish.jsonl \
  '{"type":"user","message":{"role":"user","content":"run ci"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"bash ci.sh"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"16 passed in 3.2s"}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"All green, tests pass."}]}}')
# A claim delivered via the Stop input's last_assistant_message while the transcript tail is a
# stale non-claim (the real flush-lag scenario the gate fix addresses).
TR_STALE=$(mktr stale.jsonl \
  '{"type":"user","message":{"role":"user","content":"go"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Let me sanity-check before you test."}]}}')

check "evidence: claim, no output"      ask   "$(run evidence_gate.sh "$(stopin "$TR_CLAIM")")"
check "evidence: claim + fresh pytest"  empty "$(run evidence_gate.sh "$(stopin "$TR_EVID")")"
check "evidence: delegated Task result" empty "$(run evidence_gate.sh "$(stopin "$TR_TASK")")"
check "evidence: subagent (agent_id)"   empty "$(run evidence_gate.sh "$(stopin "$TR_CLAIM" sub-123)")"
check "evidence: design turn, no claim" empty "$(run evidence_gate.sh "$(stopin "$TR_DESIGN")")"
check "evidence: no transcript"         empty "$(run evidence_gate.sh '{}')"
check "evidence: read-only contamination" ask "$(run evidence_gate.sh "$(stopin "$TR_CONTAM")")"
check "evidence: over-broad verb in file" ask "$(run evidence_gate.sh "$(stopin "$TR_OVERBROAD")")"
check "evidence: ci.sh + numeric summary" empty "$(run evidence_gate.sh "$(stopin "$TR_CISH")")"
check "evidence: claim via input field"   ask "$(printf '{"hook_event_name":"Stop","transcript_path":"%s","last_assistant_message":"The bug is fixed and all tests pass."}' "$TR_STALE" | bash "$HOOKS/evidence_gate.sh")"

# SubagentStop variant: off by default, gates only when RWF_SUBAGENT_EVIDENCE is set.
SUBA=$(printf '{"hook_event_name":"SubagentStop","agent_id":"s1","transcript_path":"%s","last_assistant_message":"The bug is fixed and all tests pass."}' "$TR_STALE")
check "subagent-stop: gate off -> allow" empty "$(printf '%s' "$SUBA" | bash "$HOOKS/evidence_gate.sh")"
check "subagent-stop: gate on -> block"  ask   "$(printf '%s' "$SUBA" | RWF_SUBAGENT_EVIDENCE=1 bash "$HOOKS/evidence_gate.sh")"

# --- no-secrets-in-git (staged-content layer; needs a real git repo) ---
if command -v git >/dev/null 2>&1; then
  mkrepo() { git init -q "$1" && git -C "$1" config user.email t@e.st && git -C "$1" config user.name test; }
  commitin() { printf '{"tool_input":{"command":"git commit -m x"},"cwd":"%s"}' "$1"; }
  SECREPO="$TMPD/secrepo"; mkrepo "$SECREPO"
  printf 'aws_secret_access_key=AKIAIOSFODNN7EXAMPLE\n' > "$SECREPO/conf.py"; git -C "$SECREPO" add conf.py
  check "secrets: AWS key in staged diff"  ask   "$(run no_secrets_in_git.sh "$(commitin "$SECREPO")")"
  CLEANREPO="$TMPD/cleanrepo"; mkrepo "$CLEANREPO"
  printf 'def f():\n    return 42\n' > "$CLEANREPO/ok.py"; git -C "$CLEANREPO" add ok.py
  check "secrets: clean commit allowed"    empty "$(run no_secrets_in_git.sh "$(commitin "$CLEANREPO")")"
  ENVREPO="$TMPD/envrepo"; mkrepo "$ENVREPO"
  printf 'SECRET=hunter2\n' > "$ENVREPO/.env"; git -C "$ENVREPO" add -f .env
  check "secrets: .env staged by name"     ask   "$(run no_secrets_in_git.sh "$(commitin "$ENVREPO")")"
else
  printf 'SKIP: no-secrets-in-git staged-content tests (git not found)\n'
fi

# --- no-stub-when-done Stop gate ---
TR_STUB=$(mktr stub.jsonl \
  '{"type":"user","message":{"role":"user","content":"implement solve()"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Write","input":{"file_path":"solver.py","new_string":"def solve():\n    raise NotImplementedError  # TODO finish"}}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"draft"}]}}')
TR_REAL=$(mktr real.jsonl \
  '{"type":"user","message":{"role":"user","content":"implement solve()"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Write","input":{"file_path":"solver.py","new_string":"def solve():\n    return integrate(f, 0, 1)"}}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"draft"}]}}')
TR_MDSTUB=$(mktr mdstub.jsonl \
  '{"type":"user","message":{"role":"user","content":"write notes"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Write","input":{"file_path":"notes.md","new_string":"# Notes\n- TODO: add more"}}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"draft"}]}}')
stubin() { printf '{"hook_event_name":"Stop","transcript_path":"%s","last_assistant_message":"%s"}' "$1" "$2"; }

check "stub: done-claim + NotImplemented" ask   "$(run no_stub_when_done.sh "$(stubin "$TR_STUB" "The implementation is complete and ready to use.")")"
check "stub: done-claim, no stub"         empty "$(run no_stub_when_done.sh "$(stubin "$TR_REAL" "The implementation is complete and ready to use.")")"
check "stub: stub but no done-claim"      empty "$(run no_stub_when_done.sh "$(stubin "$TR_STUB" "Here is a first draft; I still need to write solve().")")"
check "stub: TODO in markdown not code"   empty "$(run no_stub_when_done.sh "$(stubin "$TR_MDSTUB" "The notes are complete.")")"
check "stub: subagent exempt"             empty "$(printf '{"hook_event_name":"Stop","transcript_path":"%s","agent_id":"s1","last_assistant_message":"The implementation is complete."}' "$TR_STUB" | bash "$HOOKS/no_stub_when_done.sh")"

# --- opt-in debug logging (RWF_HOOK_DEBUG / _log.sh) ---
# Env prefixes are placed on the external `bash` invocation so they are exported into the
# hook subprocess (a `VAR=v run …` prefix would not reach the child bash).
assert() { # name  condition(0=pass)
  if [ "$2" -eq 0 ]; then printf 'PASS: %-34s (ok)\n' "$1"; pass=$((pass+1))
  else printf 'FAIL: %-34s\n' "$1"; fail=$((fail+1)); fi
}
DBGLOG="$TMPD/hooks-debug.log"
rm -f "$DBGLOG"
printf '%s' '{"tool_input":{"command":"rm -rf build"}}' | RWF_HOOK_DEBUG=1 RWF_HOOK_LOG="$DBGLOG" bash "$HOOKS/deletion_gate.sh" >/dev/null
grep -q '\[deletion\] ask:destructive' "$DBGLOG" 2>/dev/null; assert "debug: logs when enabled" $?
rm -f "$DBGLOG"
printf '%s' '{"tool_input":{"skill":"research-workflow:numerical-precision"}}' | RWF_HOOK_DEBUG=1 RWF_HOOK_LOG="$DBGLOG" bash "$HOOKS/skill_activation.sh" >/dev/null
grep -q '\[skill\] invoke:research-workflow:numerical-precision' "$DBGLOG" 2>/dev/null; assert "skill-activation: logs invoke" $?
rm -f "$DBGLOG"
# `env -u` clears any ambient RWF_HOOK_DEBUG (e.g. exported via settings.json) so this case
# actually tests the default-off behaviour rather than inheriting a set value from the shell.
printf '%s' '{"tool_input":{"command":"rm -rf build"}}' | env -u RWF_HOOK_DEBUG RWF_HOOK_LOG="$DBGLOG" bash "$HOOKS/deletion_gate.sh" >/dev/null
[ ! -f "$DBGLOG" ]; assert "debug: silent by default" $?

# --- SessionStart jq sanity check (session_check.sh) ---
check "session: jq present -> silent"  empty "$(printf '{}' | bash "$HOOKS/session_check.sh")"
# PATH=/nonexistent guarantees jq is unreachable on every platform (on merged-/usr Linux,
# /bin still contains jq). Invoke via the absolute "$BASH" — with PATH cleared, a bare `bash`
# would itself fail to resolve. session_check uses only bash builtins, so it runs and warns.
check "session: jq missing -> warns"   ask   "$(printf '{}' | PATH=/nonexistent "$BASH" "$HOOKS/session_check.sh")"

echo "----"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
