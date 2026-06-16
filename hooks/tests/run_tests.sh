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

check "evidence: claim, no output"      ask   "$(run evidence_gate.sh "$(stopin "$TR_CLAIM")")"
check "evidence: claim + fresh pytest"  empty "$(run evidence_gate.sh "$(stopin "$TR_EVID")")"
check "evidence: delegated Task result" empty "$(run evidence_gate.sh "$(stopin "$TR_TASK")")"
check "evidence: subagent (agent_id)"   empty "$(run evidence_gate.sh "$(stopin "$TR_CLAIM" sub-123)")"
check "evidence: design turn, no claim" empty "$(run evidence_gate.sh "$(stopin "$TR_DESIGN")")"
check "evidence: no transcript"         empty "$(run evidence_gate.sh '{}')"

echo "----"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
