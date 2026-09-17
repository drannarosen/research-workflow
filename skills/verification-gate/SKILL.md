---
name: verification-gate
description: Use before claiming a research coding task is complete, fixed, converged, or parity-improving so that verification is reported in a strict evidence-first close-out format. Don't use for per-command discipline mid-run (→ evidence-first-execution), validating a numerical method against its theory (→ numerical-method-validation), or archiving results across sessions (→ artifact-first-reproducibility).
---

# Verification Gate

## Overview

Do not close out a research change with “it looks good.” Pass through a
verification gate first — sized to the change. A scientific claim (a result, a
convergence or parity statement, a physics change) gets the full format below. A
small engineering fix (a docstring, a rename, a bug with a focused test) gets one
line: what changed, the command that proves it, and its output.

## Validation stages (canonical — other skills cite this)

Validation is staged; don't demand the late stage early. Analytic checks are first-class and belong in development, not at the end.

- **Physics-checked (development).** Magnitude, units, sign, scaling, and conservation trend make physical sense and the supervising scientist accepts the number. Self-consistency diagnostics (residuals, convergence with resolution, invariant drift) belong here too.
- **Analytic-checked (development — use whenever possible).** The code reproduces something known in closed form: an exact or manufactured solution, a limiting case (test-particle, Keplerian, isothermal, linear regime), a known scaling or asymptotic rate, a symmetry, or a closed-form secular/averaged rate. These are cheap, need no other code, and catch sign and factor errors early — reach for one as soon as a module can produce the quantity, and prefer it over waiting for an external comparison. Each new physics term should get its analytic limit test when it is added.
- **Externally validated (at or near the end).** Before a result is published, released, handed to others to build on, or described as validated or matching a reference, compare against a published result or a reference code (→ `reference-parity-audit`). Do **not** require running another code (MESA, another N-body code) or reproducing a published figure during development; name it once as owed and move on.

Label which stage a reported number has reached: **physics-checked**, **analytic-checked**, or **externally validated**. Never present an earlier stage as a later one.

## Required close-out format

1. What changed
2. Exact command or test run
3. Solver/physics configuration and code version (integrator + settings, physics options, commit/build)
4. Measured outputs **with units**
5. Pass/fail against an explicit criterion
6. What is proven — and the state it proves it from: **solved** (converged this run), **rebuilt** (reconstructed/cached), or **projected** (extrapolated, not directly computed)
7. What is not yet proven — including, when the result is only physics-checked, the external validation still owed at the milestone
8. Decision status: go / no-go / conditional

## Rules

1. No success claims without command-backed evidence.
2. No bare test counts without scientific interpretation.
3. Report every quantity with units, and confirm the equation/result is **dimensionally consistent** (a silent unit-system mix is a common bug; the unit facts live in `astro-code-dev` (other plugin)).
4. If verification was not run, say so plainly.
5. If the result is self-consistency or physics-checked only, label it that way — that is a legitimate development state, not a failure.
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

## Rationalizations

| Excuse | Reality |
|---|---|
| "It obviously works, I don't need to paste output." | Then pasting it costs nothing. No output = not run. |
| "The number looks physical, that's enough." | A plausible number is the failure mode, not the proof — state pass/fail vs an explicit criterion. |
| "Energy is conserved, so it's correct." | Self-consistency ≠ physical truth. Label it self-consistency only (item 6). |
| "It matches the reference's shape." | Shape resemblance is "analogy only", not parity (→ `reference-parity-audit`). |
| "Units are fine, I'll skip the check." | Silent unit-system mixes are a top bug class — confirm dimensional consistency anyway. |

## Red flags

- About to write "works", "fixed", "converged", or "parity" without a command + its output in the same message.
- A bare test count ("142 passed") with no statement of what it means physically.
- A reported quantity with no unit attached.
- "What is proven" stated without its solved / rebuilt / projected label.
- Decision status omitted or hedged into prose instead of go / no-go / conditional.

## Related

- `superpowers:verification-before-completion` (other plugin) — the general "did you actually run it?" law; this gate adds the scientific layer on top (units, physical interpretation, precision, solved/rebuilt/projected provenance).
- `evidence-first-execution` — the per-command discipline that feeds this gate.
- `numerical-method-validation` — when the claim is about a numerical method's correctness (convergence/conservation).
- `artifact-first-reproducibility` — where the close-out evidence is durably recorded.
- `reference-parity-audit` — when the claim being gated is parity with a reference implementation.
