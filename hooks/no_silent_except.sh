#!/usr/bin/env bash
# research-workflow HITL: never silently swallow an exception. Flags new Python that catches an
# error and does nothing — a bare `except:`, or `except ...:` whose only body is pass/.../continue.
# Silent swallows hide NaNs, non-convergence, and dropped data: the exact failures research code
# must surface. Path-scoped to *.py; comment-guarded; asks (never hard-denies); fails open.
set -uo pipefail
__d="${0%/*}"; [ "$__d" = "$0" ] && __d="."
[ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
command -v jq >/dev/null 2>&1 || { rwf_log no-silent-except "allow:no-jq"; exit 0; }
input=$(cat)
fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
case "$fp" in
  *.py) ;;
  *) rwf_log no-silent-except "allow:path-inert" "$fp"; exit 0 ;;
esac
newc=$(printf '%s' "$input" | jq -r '[.tool_input.new_string, .tool_input.content, (.tool_input.edits[]?.new_string)] | map(select(.!=null)) | join("\n")' 2>/dev/null) || exit 0
[ -n "$newc" ] || { rwf_log no-silent-except "allow:no-content"; exit 0; }

# Detect a silent swallow. Three forms, each guarded so a comment line never trips it:
#   inline:  except Foo: pass         (pass/.../continue on the except line)
#   bare:    except:                  (bare except is itself the anti-pattern)
#   block:   except Foo:\n    pass    (sole body on the following line)
hit=$(printf '%s\n' "$newc" | awk '
  $0 !~ /^[[:space:]]*#/ && /except[^:#]*:[[:space:]]*(pass|\.\.\.|continue)([[:space:]]|;|$)/ { print "inline" }
  $0 !~ /^[[:space:]]*#/ && /^[[:space:]]*except[[:space:]]*:/ { print "bare-except" }
  prev !~ /^[[:space:]]*#/ && prev ~ /except[^#]*:[[:space:]]*(#.*)?$/ && $0 ~ /^[[:space:]]*(pass|\.\.\.|continue)[[:space:]]*$/ { print "block" }
  { prev=$0 }
')
if [ -n "$hit" ]; then
  rwf_log no-silent-except "ask:silent-except" "$fp"
  printf '%s\n' '{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":"research-workflow no-silent-except gate: this edit catches an exception and does nothing (a bare except, or except ...: pass/.../continue). Silent swallows hide NaNs, non-convergence, and dropped data — the failures research code must surface. Handle it, or log-and-re-raise, or narrow the except to the specific error; if a no-op is genuinely intended, add a comment saying why (see no-silent-except)."}'
else
  rwf_log no-silent-except "allow:clean" "$fp"
fi
exit 0
