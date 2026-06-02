---
name: high-impact-checkpoint
description: Use before any high-impact research action — changing equation/boundary/source-term ownership, breaking a public API, replacing a canonical lane, or launching an expensive sweep or long run — so the human supervisor can review the actual decision, expected evidence, and architectural risk first. Don't use for the ongoing session collaboration stance (→ researcher-in-the-loop) or the post-task close-out format (→ verification-gate).
---

# High-Impact Checkpoint

## Overview

This is a **HARD gate**: you MUST checkpoint before any trigger below and wait for
the supervising scientist's go. Stop and present the scientific decision clearly —
treat the human as the supervisor, not a bystander. (This is not an adaptable
default; the *content* of the checkpoint flexes, the gate does not.)

## Trigger conditions

- changing equation ownership
- changing boundary-condition ownership
- changing source-term ownership (e.g. `eps_grav` in stellar work, the force kernel in N-body)
- breaking a public or widely used internal API
- replacing a canonical lane
- starting a run expected to exceed a meaningful cost threshold for the project (e.g. minutes, GPU time, or a large sweep)
- beginning a sweep, grid, or multi-case comparison

## Required checkpoint

State only these items:

1. Current step
2. Wrong owner or blocker
3. Proposed new owner or cutover
4. Exact command or implementation slice
5. Expected runtime or implementation risk
6. Expected evidence if successful
7. What would falsify the plan

Items 4–7 **are** the falsifiable slice from `minimal-falsifiable-slice` — scope it there, restate it here; do not re-derive.

## Worked example (computational astrophysics)

> "Step: our N-body force kernel uses a fixed softening ε. Proposed cutover: make ε **solver-owned** per the half-mass radius instead of a hardcoded constant (changes source-term ownership → trigger). Slice: edit `softening.py` only; run the 1000-particle Plummer two-body energy test, IAS15, tol 1e-9. Risk: ~2 min. Expected evidence: |ΔE/E| < 1e-13 unchanged. Falsified if energy drift worsens or virial Q drifts off 0.5. Go/no-go?"

## Rules

1. Keep the checkpoint short and scientific.
2. Do not bury the decision in broad status prose.
3. Make the tradeoff explicit if there is one.
4. If there is no real decision, do not fake a checkpoint.

## Rationalizations

| Excuse | Reality |
|---|---|
| "It's a quick change, no need to stop." | Quick edits to equation/source/boundary ownership are exactly the triggers. Gate it. |
| "I'll just kick off the sweep and report when it's done." | An expensive run with no pre-stated expected evidence is a triggered action. Checkpoint first. |
| "The API break is internal-only." | Replacing a canonical lane or widely-used internal API is a trigger regardless of visibility. |
| "I'll surface the owner change after it works." | The point of the gate is review *before* implementation drift, not after. |

## Red flags

- About to edit who owns an equation / boundary condition / source term without a stated checkpoint.
- Launching a sweep, grid, or long/GPU run before naming the evidence it must produce.
- Replacing or deleting a canonical lane mid-task without supervisor go.
- Decision is buried inside broad status prose instead of the 7-item block.

## Related

- `researcher-in-the-loop` — the broader ongoing engagement stance this checkpoint sits inside.
- `minimal-falsifiable-slice` — scope the action (items 4–7) before you gate it.
- `verification-gate` — the close-out once the gated action is done.
