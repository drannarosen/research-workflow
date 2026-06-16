---
description: Go/no-go checkpoint before an expensive or irreversible run (high-impact-checkpoint).
argument-hint: [what you're about to run, e.g. "the 10M-particle production integration"]
---
Use the `high-impact-checkpoint` skill to gate this action before it runs: $ARGUMENTS

If no action was given, identify the most significant pending or proposed action in this session and gate that.

Present a concise go/no-go:
- the action and its cost (compute / wall-time / money / quota),
- reversibility (can we undo it, and how cheaply),
- the cheapest pre-check that would catch a wasted run (a smoke run, a smaller N, a dry run),
- what result means success vs. wasted spend,
- a single clear recommendation (go / no-go / go-after-precheck).

Do not start the action until I explicitly approve.
