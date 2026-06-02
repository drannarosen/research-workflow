---
name: evidence-first-execution
description: Use when running research commands or verification so that each command is pre-announced, each result is reported with units, and no convergence or parity claim is made without direct command evidence. Don't use for the end-of-task close-out format (→ verification-gate) or recording durable artifacts across sessions (→ artifact-first-reproducibility).
---

# Evidence-First Execution

## Overview

One command at a time. Evidence first. No success language without output.

## Before each meaningful command

State:

1. Current step
2. Scientific invariant being protected
3. Exact command
4. Expected runtime

## After each meaningful command

State:

1. Key outputs with units
2. Whether the criterion passed or failed
3. Whether the state shown is solved, rebuilt, or projected
4. One next action

## Rules

1. No bare test counts without scientific interpretation.
2. No raw residual norms without equation-family translation.
3. No “passes”, “works”, or “reference parity” claims without file-backed evidence.
4. For high-cost runs, do the minimum representative high-precision case first.

## Anti-patterns

- Batch-running broad suites without a decision need
- Treating self-consistency checks as physical validation
- Reporting solver-space norms as if they were direct physics truth

## Related

- `verification-gate` — the strict close-out format once the task is done.
- `artifact-first-reproducibility` — turn the evidence into durable, rerunnable artifacts.
