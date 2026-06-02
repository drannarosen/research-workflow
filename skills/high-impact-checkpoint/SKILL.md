---
name: high-impact-checkpoint
description: Use before any high-impact research action so the human supervisor can review the actual decision, expected evidence, and architectural risk before implementation or expensive runs proceed. Don't use for the ongoing session collaboration stance (→ researcher-in-the-loop) or the post-task close-out format (→ verification-gate).
---

# High-Impact Checkpoint

## Overview

Before high-impact work, stop and present the scientific decision clearly.
Treat the human as the supervising scientist, not a bystander.

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

## Rules

1. Keep the checkpoint short and scientific.
2. Do not bury the decision in broad status prose.
3. Make the tradeoff explicit if there is one.
4. If there is no real decision, do not fake a checkpoint.

## Anti-patterns

- starting a major rewrite without surfacing the owner change
- running expensive jobs before stating what evidence they are meant to produce
- giving the human implementation details without the scientific decision

## Related

- `researcher-in-the-loop` — the broader ongoing engagement stance this checkpoint sits inside.
- `minimal-falsifiable-slice` — scope the action before you gate it.
- `verification-gate` — the close-out once the gated action is done.
