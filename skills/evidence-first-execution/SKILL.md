---
name: evidence-first-execution
description: Use when running research commands or verification so that each command is pre-announced, each result is reported with units, and no convergence or parity claim is made without direct command evidence. Don't use for the end-of-task close-out format (→ verification-gate) or recording durable artifacts across sessions (→ artifact-first-reproducibility).
---

# Evidence-First Execution

## Overview

One command at a time. Evidence first. No success language without output.

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
2. **Translate residual norms into the physics they bound.** A raw `‖r‖₂` means nothing until mapped to the equation family it came from. *Worked example:* an L2 residual of `1e-8` on the discretized momentum equation (in code units where the characteristic force density is `O(1)`) means the largest local force imbalance is ~`1e-8` of a dynamical force — i.e. negligible vs the physics, not "small because the number is small." Report the physical imbalance, not the bare norm.
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
