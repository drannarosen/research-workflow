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

echo "----"
printf '%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
