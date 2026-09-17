---
name: evidence-first-execution
description: Use when running research commands or verification so that each command is pre-announced, each result is reported with units, and no convergence or parity claim is made without direct command evidence. Don't use for the end-of-task close-out format (→ verification-gate) or recording durable artifacts across sessions (→ artifact-first-reproducibility).
---

# Evidence-First Execution

## Overview

One *consequential* command at a time — runs, solves, and edits whose output you will interpret. Read-only exploration (reading files, grepping, listing) can be batched in parallel. Evidence first. No success language without output.

**Hard:** no convergence, parity, or done claim without direct command output. **Adaptable:** the reporting cadence and format.

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

## Rules (unique to per-command execution)

The shared "no success language without command-backed evidence / no bare test counts / no unbacked parity" rules live in `verification-gate` — don't restate them, apply them. What is specific here:

1. **Pre-announce / post-report cadence** — every meaningful command gets the before-block and after-block above; never fire a run and narrate it only after the fact.
2. **Translate residual norms into the physics they bound — and don't mistake a small residual for a small error.** A raw `‖r‖` means nothing until mapped to the equation family and norm it came from. *Worked example:* an L2 residual of `1e-8` on the discretized momentum equation (code units, characteristic force density `O(1)`) bounds every local force imbalance by `1e-8` of a dynamical force — but an **RMS**-normalized residual of `1e-8` over N cells allows a local imbalance up to `√N·1e-8`, and in either case the *solution* error is only bounded by the condition number: `‖e‖/‖x‖ ≤ κ(J)·‖r‖/‖b‖`. For a stiff Newton solve (κ ~ 1e8 is common in stellar structure) a `1e-8` residual can leave O(1) relative error in a poorly conditioned direction. Report which norm, the physical imbalance, and whether κ was estimated.
3. **Label the state shown** as solved / rebuilt / projected on every result (see after-block) — a cached or extrapolated number is not a freshly solved one.
4. **For high-cost runs, do the minimum representative high-precision case first** — one tight tolerance / fine-resolution case to anchor truth before sweeping cheap-but-approximate runs.

## Anti-patterns

- Batch-running broad suites without a decision need
- Treating self-consistency checks as physical validation
- Reporting solver-space norms as if they were direct physics truth

## Related

- `superpowers:verification-before-completion` (other plugin) — the general "run it and show the output before claiming success" law; this skill is its per-command cadence with the scientific layer (units, residual→physics, solved/rebuilt/projected).
- `verification-gate` — the strict close-out format once the task is done; owns the shared evidence rules this skill applies.
- `artifact-first-reproducibility` — turn the evidence into durable, rerunnable artifacts.
