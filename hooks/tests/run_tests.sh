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
check "prov: declared postulate"    empty "$(run provenance.sh '{"tool_input":{"file_path":"pkg/coefficients.py","new_string":"v_c = 3.0e4  # declared postulate: drag threshold (assumption-ledger A3)"}}')"
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
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"Implemented X. Verification: pytest -q -> 5 passed."}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Done — the subagent implemented X and tests pass."}]}}')
TR_TASK_WEAK=$(mktr task-weak.jsonl \
  '{"type":"user","message":{"role":"user","content":"implement X"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Task","input":{"description":"implement X"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"Implemented X and updated the files."}]}}' \
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
check "evidence: weak Task no evidence" ask "$(run evidence_gate.sh "$(stopin "$TR_TASK_WEAK")")"
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
stubin_cwd() { printf '{"hook_event_name":"Stop","transcript_path":"%s","cwd":"%s","last_assistant_message":"%s"}' "$1" "$2" "$3"; }
PRE_DIR="$TMPD/preexisting"; mkdir -p "$PRE_DIR"
printf 'def solve():
    raise NotImplementedError  # TODO finish

def helper():
    return 1
' > "$PRE_DIR/solver.py"
TR_PREEXIST=$(mktr preexist.jsonl \
  '{"type":"user","message":{"role":"user","content":"finish solver"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Edit","input":{"file_path":"solver.py","old_string":"def helper():","new_string":"def helper():"}}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"draft"}]}}')

check "stub: done-claim + NotImplemented" ask   "$(run no_stub_when_done.sh "$(stubin "$TR_STUB" "The implementation is complete and ready to use.")")"
check "stub: done-claim, no stub"         empty "$(run no_stub_when_done.sh "$(stubin "$TR_REAL" "The implementation is complete and ready to use.")")"
check "stub: stub but no done-claim"      empty "$(run no_stub_when_done.sh "$(stubin "$TR_STUB" "Here is a first draft; I still need to write solve().")")"
check "stub: TODO in markdown not code"   empty "$(run no_stub_when_done.sh "$(stubin "$TR_MDSTUB" "The notes are complete.")")"
check "stub: pre-existing, not edited"  empty  "$(run no_stub_when_done.sh "$(stubin_cwd "$TR_PREEXIST" "$PRE_DIR" "The implementation is complete and ready to use.")")"
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

# --- inference/precision Stop gate (inference_precision_gate.sh) ---
# (R) a reported posterior estimate needs sampler diagnostics (R-hat/ESS) somewhere in the turn;
# (P) in a JAX project, a reported error/drift/residual below float32 reach (~1e-7) needs x64 evidence.
# Both exempt anything labeled exploratory/preliminary, and subagents.
ipg() { # transcript  message  [cwd]
  jq -nc --arg tp "$1" --arg m "$2" --arg cwd "${3:-$TMPD}" '{hook_event_name:"Stop",transcript_path:$tp,last_assistant_message:$m,cwd:$cwd}' | bash "$HOOKS/inference_precision_gate.sh"; }
TR_RHAT=$(mktr rhat.jsonl \
  '{"type":"user","message":{"role":"user","content":"fit it"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"uv run fit.py"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"      mean  std  median  5.0%  95.0%  n_eff  r_hat\n  m   1.42 0.08   1.42   1.29   1.55  1843.2  1.00"}]}}')
check "ipg: posterior, no diagnostics"   ask   "$(ipg "$TR_STALE" "The posterior gives M = 1.42 ± 0.08 Msun (68% credible interval).")"
check "ipg: posterior + r_hat in output" empty "$(ipg "$TR_RHAT"  "The posterior gives M = 1.42 ± 0.08 Msun (68% credible interval).")"
check "ipg: posterior + R-hat in message" empty "$(ipg "$TR_STALE" "The posterior gives M = 1.42 ± 0.08 Msun (R-hat 1.003, bulk ESS 1200).")"
check "ipg: posterior, exploratory"      empty "$(ipg "$TR_STALE" "Exploratory NUTS run: posterior median 1.4 ± 0.1, not yet converged-checked.")"
check "ipg: posterior talk, no estimate" empty "$(ipg "$TR_STALE" "Next I will look at the shape of the posterior before fitting the second model.")"
JAXREPO="$TMPD/jaxrepo"; mkdir -p "$JAXREPO"; git init -q "$JAXREPO"; printf 'import jax\nimport jax.numpy as jnp\n' > "$JAXREPO/sim.py"; git -C "$JAXREPO" add sim.py
X64REPO="$TMPD/x64repo"; mkdir -p "$X64REPO"; git init -q "$X64REPO"; printf 'import jax\njax.config.update("jax_enable_x64", True)\n' > "$X64REPO/sim.py"; git -C "$X64REPO" add sim.py
PLAINREPO="$TMPD/plainrepo"; mkdir -p "$PLAINREPO"; git init -q "$PLAINREPO"; printf 'import numpy as np\n' > "$PLAINREPO/sim.py"; git -C "$PLAINREPO" add sim.py
check "ipg: jax, 3e-12 drift, no x64"    ask   "$(ipg "$TR_STALE" "Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$JAXREPO")"
check "ipg: jax, drift, x64 in repo"     empty "$(ipg "$TR_STALE" "Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$X64REPO")"
check "ipg: numpy repo, tiny drift"      empty "$(ipg "$TR_STALE" "Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$PLAINREPO")"
check "ipg: jax, 2e-5 error (f32 ok)"    empty "$(ipg "$TR_STALE" "Relative error is 2e-5 at the finest grid." "$JAXREPO")"
check "ipg: jax, tiny density not error" empty "$(ipg "$TR_STALE" "The envelope density reaches 1e-12 g cm^-3 at the photosphere." "$JAXREPO")"
check "ipg: jax, residual 1.0e-10"       ask   "$(ipg "$TR_STALE" "Newton converged: residual norm 1.0e-10 after 6 iterations." "$JAXREPO")"
TR_X64CMD=$(mktr x64cmd.jsonl \
  '{"type":"user","message":{"role":"user","content":"run"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"JAX_ENABLE_X64=1 uv run sim.py"}}]}}')
check "ipg: jax, x64 via env in command" empty "$(ipg "$TR_X64CMD" "Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$JAXREPO")"
check "ipg: jax, tiny density + big error in separate sentences" empty "$(ipg "$TR_STALE" "The envelope density reaches 1e-12 g cm^-3 at the photosphere. The relative error of the fit is 2e-3." "$JAXREPO")"
TR_ESSONLY=$(mktr essonly.jsonl \
  '{"type":"user","message":{"role":"user","content":"fit"}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"bulk ESS 1843 tail ESS 1502 divergences 0"}]}}')
check "ipg: posterior + ESS-only output" empty "$(ipg "$TR_ESSONLY" "The posterior gives M = 1.42 ± 0.08 Msun (68% credible interval).")"
check "ipg: subagent exempt"             empty "$(jq -nc --arg tp "$TR_STALE" '{hook_event_name:"Stop",agent_id:"s1",transcript_path:$tp,last_assistant_message:"The posterior gives M = 1.42 ± 0.08 (68% credible interval)."}' | bash "$HOOKS/inference_precision_gate.sh")"

# --- turn scoping: evidence must come from the CURRENT turn (since the last real user prompt) ---
TR_PREVTURN=$(mktr prevturn.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix bug X"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"pytest -q"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"3 passed in 0.4s"}]}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"Fixed X."}]}}' \
  '{"type":"user","message":{"role":"user","content":"now fix bug Y too"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The bug is fixed and all tests pass."}]}}')
check "turn: evidence only in previous turn" ask "$(run evidence_gate.sh "$(stopin "$TR_PREVTURN")")"
LONGTURN="$TMPD/longturn.jsonl"
{ printf '%s\n' '{"type":"user","message":{"role":"user","content":"fix the bug"}}' \
    '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"pytest -q"}}]}}' \
    '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"12 passed in 1.1s"}]}}'
  for i in $(seq 300); do printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Read","input":{"file_path":"src/a.py"}}]}}'; done
  printf '%s\n' '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The bug is fixed and all tests pass."}]}}'; } > "$LONGTURN"
check "turn: long turn, evidence early"  empty "$(run evidence_gate.sh "$(stopin "$LONGTURN")")"
TR_HOOKFB=$(mktr hookfb.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix the bug"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"pytest -q"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"3 passed in 0.4s"}]}}' \
  '{"type":"user","isMeta":true,"message":{"role":"user","content":"Stop hook feedback: research-workflow evidence gate ..."}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"All tests pass now."}]}}')
check "turn: hook feedback is not a new turn" empty "$(run evidence_gate.sh "$(stopin "$TR_HOOKFB")")"

# --- install freshness (SessionStart): warn when the installed copy differs from its source repo ---
FRESH="$TMPD/fresh"; mkdir -p "$FRESH/src/skills/a" "$FRESH/src/hooks" "$FRESH/cache/research-workflow-dev/research-workflow/1.1.0"
printf 'skill A\n' > "$FRESH/src/skills/a/SKILL.md"; printf 'echo hook\n' > "$FRESH/src/hooks/h.sh"
cp -R "$FRESH/src/skills" "$FRESH/src/hooks" "$FRESH/cache/research-workflow-dev/research-workflow/1.1.0/"
printf '{"research-workflow-dev":{"source":{"source":"directory","path":"%s"},"installLocation":"%s"}}' "$FRESH/src" "$FRESH/src" > "$FRESH/known.json"
fresh() { printf '{}' | CLAUDE_PLUGIN_ROOT="$FRESH/cache/research-workflow-dev/research-workflow/1.1.0" RWF_KNOWN_MARKETPLACES="$FRESH/known.json" bash "$HOOKS/install_freshness.sh"; }
check "fresh: installed == source"      empty "$(fresh)"
printf 'skill A, edited\n' > "$FRESH/src/skills/a/SKILL.md"
check "fresh: source edited -> warn"    ask   "$(fresh)"
printf '{}' > "$FRESH/known.json"
check "fresh: no marketplace entry"     empty "$(fresh)"
check "fresh: no plugin root"           empty "$(printf '{}' | env -u CLAUDE_PLUGIN_ROOT bash "$HOOKS/install_freshness.sh")"

# --- large-input regressions (SIGPIPE under pipefail) ---
# `printf "$big" | grep -q` fails when grep -q exits on an early match while printf is still
# writing more than a pipe buffer (~64 KB): printf gets SIGPIPE and pipefail reports the
# pipeline as failed, so a MATCH read as a miss. Every fixture puts the signal first, then
# >64 KB of padding. Found 2026-09-16: a secret in a 618 KB staged diff was silently allowed.
PADN=$(printf '# padding line for pipe-buffer overflow\n%.0s' $(seq 4000))     # ~160 KB, real newlines
PADW=$(printf 'padding %.0s' $(seq 20000))                                     # ~160 KB, one line
# Build large JSON with jq so the fixture is always valid JSON (hand-escaped >64 KB strings
# inside nested "$(…)" quoting get brace-expanded by bash and silently corrupt the input).
# Large strings go through stdin, never argv: Linux caps a single argument at 131072 bytes (E2BIG).
bigedit() { printf '%s' "$3" | jq -Rsc --arg tool "$1" --arg fp "$2" '{tool_name:$tool,tool_input:{file_path:$fp,new_string:.}}'; }
check "large: deletion rm first"        ask   "$(run deletion_gate.sh "$(printf '%s' "rm -rf build; echo $PADW" | jq -Rsc '{tool_input:{command:.}}')")"
check "large: test skip first"          ask   "$(run test_integrity.sh "$(bigedit Edit tests/test_x.py "@pytest.mark.skip
$PADN")")"
check "large: prov uncited literal"     ask   "$(run provenance.sh "$(bigedit Edit pkg/constants.py "eta = 0.1
$PADN")")"
check "large: prov cited literal"       empty "$(run provenance.sh "$(bigedit Edit pkg/constants.py "eta = 0.1  # Frank, King & Raine 2002
$PADN")")"
check "large: myst legacy syntax first" ask   "$(run myst_docs_hygiene.sh "$(bigedit Edit p/docs/x.md "{toctree}
$PADN")")"
check "large: evidence claim first"     ask   "$(printf '{"hook_event_name":"Stop","transcript_path":"%s","last_assistant_message":"The bug is fixed and all tests pass. %s"}' "$TR_STALE" "$PADW" | bash "$HOOKS/evidence_gate.sh")"
check "large: stub claim first"         ask   "$(run no_stub_when_done.sh "$(stubin "$TR_STUB" "The implementation is complete and ready to use. $PADW")")"
TR_BIGEVID=$(mktr bigevid.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix the bug"}}' \
  "{\"type\":\"assistant\",\"message\":{\"role\":\"assistant\",\"content\":[{\"type\":\"tool_use\",\"name\":\"Bash\",\"input\":{\"command\":\"pytest -q\"}},{\"type\":\"tool_use\",\"name\":\"Bash\",\"input\":{\"command\":\"echo $PADW\"}}]}}" \
  "{\"type\":\"user\",\"message\":{\"role\":\"user\",\"content\":[{\"type\":\"tool_result\",\"content\":\"3 passed in 0.4s $PADW\"}]}}" \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"All tests pass now."}]}}')
check "large: evidence ran, big output" empty "$(run evidence_gate.sh "$(stopin "$TR_BIGEVID")")"
if command -v git >/dev/null 2>&1; then
  BIGREPO="$TMPD/bigrepo"; mkrepo "$BIGREPO"
  { printf 'aws_secret_access_key=AKIAIOSFODNN7EXAMPLE\n'; seq 1 40000 | sed 's/^/x_/'; } > "$BIGREPO/conf.py"
  git -C "$BIGREPO" add conf.py
  check "large: secret in big staged diff" ask  "$(run no_secrets_in_git.sh "$(commitin "$BIGREPO")")"
  check "large: secret, git commit -a"     ask  "$(run no_secrets_in_git.sh "$(printf '{"tool_input":{"command":"git add . && git commit -m x"},"cwd":"%s"}' "$BIGREPO")")"
fi

# --- RWF_STRICTNESS: advisory (default) warns without blocking; standard blocks ---
has() { # name  jq-filter  actual-output
  if printf '%s' "$3" | jq -e "$2" >/dev/null 2>&1; then printf 'PASS: %-34s\n' "$1"; pass=$((pass+1))
  else printf 'FAIL: %-34s (got: %s)\n' "$1" "$3"; fail=$((fail+1)); fi
}
ADV=$(printf '%s' "$(stopin "$TR_CLAIM")" | env -u RWF_STRICTNESS bash "$HOOKS/evidence_gate.sh")
STD=$(printf '%s' "$(stopin "$TR_CLAIM")" | RWF_STRICTNESS=standard bash "$HOOKS/evidence_gate.sh")
has "strictness: default is advisory"   '.systemMessage and (has("decision")|not)' "$ADV"
has "strictness: standard blocks"       '.decision=="block" and (.reason|length>0)' "$STD"
has "strictness: unknown -> advisory"   '.systemMessage' "$(printf '%s' "$(stopin "$TR_CLAIM")" | RWF_STRICTNESS=bogus bash "$HOOKS/evidence_gate.sh")"

# --- stance router: opt-in only ---
check "router: off by default"          empty "$(printf '{"prompt":"x"}' | env -u RWF_STANCE_ROUTER bash "$HOOKS/stance_router.sh")"
has   "router: on emits context"        '.hookSpecificOutput.additionalContext|test("approval")' "$(printf '{"prompt":"x"}' | RWF_STANCE_ROUTER=1 bash "$HOOKS/stance_router.sh")"

# --- output schema: PreToolUse asks carry hookEventName; fallback helper is advisory ---
for spec in \
  'deletion_gate.sh|{"tool_input":{"command":"rm -rf build"}}' \
  'test_integrity.sh|{"tool_input":{"file_path":"tests/test_x.py","old_string":"rtol=0.05","new_string":"rtol=0.5"}}' \
  'provenance.sh|{"tool_input":{"file_path":"pkg/constants.py","new_string":"eta = 0.1"}}' \
  'no_silent_except.sh|{"tool_input":{"file_path":"a.py","new_string":"try:\n    f()\nexcept Exception: pass"}}' \
  'myst_docs_hygiene.sh|{"tool_name":"Write","tool_input":{"file_path":"p/docs/x.md","content":"---\ntitle: X\ndescription: y\n---\n```{toctree}\n```"}}' \
  "no_secrets_in_git.sh|$(secin "git add .env")"; do
  h="${spec%%|*}"; in="${spec#*|}"
  has "schema: $h ask shape" '.hookSpecificOutput.hookEventName=="PreToolUse" and .hookSpecificOutput.permissionDecision=="ask"' "$(run "$h" "$in")"
done
ISO="$TMPD/iso"; mkdir -p "$ISO"; cp "$HOOKS/evidence_gate.sh" "$ISO/"
has "fallback helper is advisory"   '.systemMessage and (has("decision")|not)' "$(printf '%s' "$(stopin "$TR_CLAIM")" | env -u RWF_STRICTNESS bash "$ISO/evidence_gate.sh")"
# --- turn window: a slash-command prompt starts a new turn ---
TR_SLASH=$(mktr slash.jsonl \
  '{"type":"user","message":{"role":"user","content":"fix bug X"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"tool_use","name":"Bash","input":{"command":"pytest -q"}}]}}' \
  '{"type":"user","message":{"role":"user","content":[{"type":"tool_result","content":"3 passed in 0.4s"}]}}' \
  '{"type":"user","message":{"role":"user","content":"<command-message>review</command-message>\n<command-name>/review</command-name>"}}' \
  '{"type":"assistant","message":{"role":"assistant","content":[{"type":"text","text":"The bug is fixed and all tests pass."}]}}')
check "turn: slash command is a new turn"  ask   "$(run evidence_gate.sh "$(stopin "$TR_SLASH")")"
# --- inference/precision: labels count only in the number's own sentence; x64 only from code/config ---
check "ipg: label elsewhere doesn't exempt" ask "$(ipg "$TR_STALE" "I ran a quick sanity check on the plotting script. Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$JAXREPO")"
check "ipg: label in same sentence exempts" empty "$(ipg "$TR_STALE" "Exploratory run: energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$JAXREPO")"
DOCX64="$TMPD/docx64"; mkdir -p "$DOCX64"; git -C "$DOCX64" init -q
printf 'import jax\n' > "$DOCX64/a.py"; printf 'Enable jax_enable_x64 later.\n' > "$DOCX64/NOTES.md"; git -C "$DOCX64" add . >/dev/null
check "ipg: x64 only in docs is not evidence" ask "$(ipg "$TR_STALE" "Energy drift |ΔE/E| = 3e-12 over 1000 orbits." "$DOCX64")"

echo "----"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
