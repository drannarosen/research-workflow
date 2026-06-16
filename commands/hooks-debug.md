---
description: Inspect or enable the research-workflow hook decision log (RWF_HOOK_DEBUG).
argument-hint: "[status | tail | on | off]"
---
Manage research-workflow hook observability. Argument: $ARGUMENTS (default: `status`).

The log records, per turn, which hook fired and what it decided (`allow:* / ask:* / block:*`). Logfile: `$RWF_HOOK_LOG`, default `${TMPDIR:-/tmp}/research-workflow-hooks.log`.

- **status** — report whether `RWF_HOOK_DEBUG` is set in the current environment, and the resolved logfile path and whether it exists.
- **tail** — show the last ~30 lines of the logfile if present (`tail -n 30` the resolved path).
- **on** / **off** — IMPORTANT: hooks read their environment at session start, so this cannot be toggled live. To enable, add `"RWF_HOOK_DEBUG": "1"` to the `env` block of `.claude/settings.json` (or `export RWF_HOOK_DEBUG=1` before launching Claude Code); to disable, remove it. Offer to make the `settings.json` edit, and if I confirm, make it and remind me that it takes effect only after restarting Claude Code.

State the live-toggle limitation plainly — do not imply a setting took effect this session when it did not.
