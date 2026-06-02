---
name: verification-gate
description: Use before claiming a research coding task is complete, fixed, converged, or parity-improving so that verification is reported in a strict evidence-first close-out format. Don't use for per-command discipline mid-run (→ evidence-first-execution), validating a numerical method against its theory (→ numerical-method-validation), or archiving results across sessions (→ artifact-first-reproducibility).
---

# Verification Gate

## Overview

Do not close out a research change with “it looks good.” Pass through a
verification gate first.

## Required close-out format

1. What changed
2. Exact command or test run
3. Exact model stack used
4. Measured outputs **with units**
5. Pass/fail against an explicit criterion
6. What is proven
7. What is not yet proven
8. Decision status: go / no-go / conditional

## Rules

1. No success claims without command-backed evidence.
2. No bare test counts without scientific interpretation.
3. Report every quantity with units, and confirm the equation/result is **dimensionally consistent** (a silent unit-system mix is a common bug; the unit facts live in `astro-code-dev`).
4. If verification was not run, say so plainly.
5. If the result is self-consistency only, label it that way.
6. If reference parity is claimed, the comparison must be file-backed and checkpoint-matched (→ `reference-parity-audit`).

## Minimum scientific interpretation

Every verification summary must say:

- what the numbers mean physically
- what they do not mean physically
- the current blocker if the task is not complete

## Anti-patterns

- “tests pass” with no physics interpretation
- “converged” when only a diagnostic proxy improved
- “parity” when only the implementation shape resembles the reference

## Related

- `evidence-first-execution` — the per-command discipline that feeds this gate.
- `numerical-method-validation` — when the claim is about a numerical method's correctness (convergence/conservation).
- `artifact-first-reproducibility` — where the close-out evidence is durably recorded.
- `reference-parity-audit` — when the claim being gated is parity with a reference implementation.
