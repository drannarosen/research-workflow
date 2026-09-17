---
name: high-impact-checkpoint
description: Use before any high-impact research action — changing equation/boundary/source-term ownership, breaking a public API, replacing a canonical lane, or a run above the project's cost threshold (stop and wait); sweeps and runs over ~2 minutes are announced, not blocked — so the human supervisor can review the actual decision, expected evidence, and architectural risk first. Don't use for the ongoing session collaboration stance (→ researcher-in-the-loop) or the post-task close-out format (→ verification-gate).
---

# High-Impact Checkpoint

## Overview

Two tiers. Structural and irreversible changes **stop and wait** for the supervising
scientist's go. Cost alone only requires an **announcement** — the human can interrupt,
and a scientist should not have to approve every three-point timestep scan.

## Stop and wait (hard gate)

- changing equation ownership
- changing boundary-condition ownership
- changing source-term ownership (e.g. `eps_grav` in stellar work, the force kernel in N-body)
- breaking a public or widely used internal API
- replacing or deleting a canonical lane
- a run above the project's stated cost threshold (GPU-hours, cluster allocation, quota), or one whose output would overwrite results that cannot be regenerated cheaply

## Announce, then proceed

- a sweep, grid, or multi-case comparison, or a run expected to take more than ~2 minutes: say what will run, its expected cost, the evidence it should produce, and offer to skip — then start it unless told otherwise, and say what you will do meanwhile. Use the short form (current step · command · expected cost · expected evidence), not the full block below.

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

> "Step: our N-body force kernel uses a fixed softening ε. Proposed cutover: make ε **solver-owned** per the half-mass radius instead of a hardcoded constant (changes source-term ownership → trigger). Slice: edit `softening.py` only; run the 1000-particle Plummer energy test (IAS15, 10 crossing times), with the energy diagnostic using the *same* softened potential as the forces. Risk: ~2 min. Expected evidence: max |ΔE/E| stays at IAS15's round-off floor (~1e-12 or below) and the virial ratio Q stays ≈ 0.5. Falsified if |ΔE/E| grows secularly or Q drifts. Go/no-go?"

## Rules

1. Keep the checkpoint short and scientific.
2. Do not bury the decision in broad status prose.
3. Make the tradeoff explicit if there is one.
4. If there is no real decision, do not fake a checkpoint.

## Rationalizations

| Excuse | Reality |
|---|---|
| "It's a quick change, no need to stop." | Quick edits to equation/source/boundary ownership are exactly the triggers. Gate it. |
| "I'll just kick off the sweep and report when it's done." | Announce it first — expected cost and the evidence it must produce — so the human can stop it. Silent launches are the failure, not sweeps. |
| "The API break is internal-only." | Replacing a canonical lane or widely-used internal API is a trigger regardless of visibility. |
| "I'll surface the owner change after it works." | The point of the gate is review *before* implementation drift, not after. |

## Red flags

- About to edit who owns an equation / boundary condition / source term without a stated checkpoint.
- Launching a sweep, grid, or long/GPU run without announcing its cost and the evidence it must produce.
- Replacing or deleting a canonical lane mid-task without supervisor go.
- Decision is buried inside broad status prose instead of the 7-item block.

## Related

- `researcher-in-the-loop` — the broader ongoing engagement stance this checkpoint sits inside.
- `minimal-falsifiable-slice` — scope the action (items 4–7) before you gate it.
- `verification-gate` — the close-out once the gated action is done.
