# shellcheck shell=bash
# research-workflow: shared helper for Stop hooks — print the transcript lines of the CURRENT turn,
# i.e. everything after the last real user prompt. A fixed `tail -n 250` both over-counts (evidence
# from an earlier turn) and under-counts (a long turn pushes its own evidence out of the window).
# Not a turn boundary: tool results, isMeta messages, and injected text (hook feedback, system
# reminders, task notifications). Falls back to the whole transcript if no prompt is found.
rwf_current_turn() { # transcript_path
  local tp="$1" start
  [ -n "$tp" ] && [ -r "$tp" ] || return 0
  start=$(jq -r 'select(.type=="user" and (.isMeta != true))
      | (.message.content) as $c
      | if ($c|type)=="string" then
          (if ($c|test("^\\s*(Stop hook feedback|<system-reminder|\\[SYSTEM NOTIFICATION|<task-notification|<local-command|Caveat:)")) then empty else input_line_number end)
        elif ($c|type)=="array" and ([$c[]?|select(.type=="tool_result")]|length)==0 and ([$c[]?|select(.type=="text")]|length)>0 then input_line_number
        else empty end' "$tp" 2>/dev/null | tail -n 1)
  if [ -n "$start" ]; then tail -n +"$start" "$tp"; else cat "$tp"; fi
}
