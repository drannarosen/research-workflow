---
name: numerical-method-validation
description: Use when validating a numerical method against its own theory — convergence/order-of-accuracy refinement studies, conservation/invariant checks to tolerance, oracle strategies (manufactured solutions, self-convergence, symmetry/limit checks) when no analytic truth exists, and persisting a regression baseline so verified behavior cannot silently drift. Don't use for parity against a reference implementation (→ reference-parity-audit), the general close-out format (→ verification-gate), or auditing someone else's numerics in review (→ numerical-methods-auditor).
---

Validate that a solver does what its theory claims — measured order of accuracy, conserved invariants, and stable behavior under refinement. Default to the strongest oracle available; when none exists, combine weak oracles rather than skipping validation.

## Required statement
Before claiming a method validated, write down all of:
- **Method + claim**: name + theoretical order p and/or invariants it preserves (e.g. a 4th-order symplectic integrator → p=4, bounded energy error, no secular drift).
- **Refinement sequence**: the grid spacings / timesteps used (≥3 levels, halving or fixed ratio r).
- **Measured vs theory**: observed rate from successive errors `p ≈ log(e₁/e₂)/log(r)` — must match claimed p within ~10%; a clean method drops to round-off, not a plateau.
- **Invariant + tolerance**: which quantity, absolute/relative tol, and over what horizon (drift matters more than instantaneous error for long integrations).

## Oracle ladder (use the highest rung you can reach)
1. **Analytic solution** — exact error; the gold standard when the problem has one.
2. **Manufactured solution** — insert a chosen exact solution, derive the forcing term it requires, then recover it. Tests the discretization, not the physics.
3. **Richardson / self-convergence** — three resolutions, no truth needed: confirm errors shrink at rate r^p and Richardson-extrapolate the "true" value.
4. **Conservation as weak oracle** — an invariant holding to tolerance is necessary, not sufficient; a bug can conserve energy and still be wrong.
5. **Symmetry / limit checks** — time-reversibility, reflection, known asymptotic regime (e.g. recover Keplerian closure or the diffusion limit). Cheap, catches sign/factor errors.

## Anti-patterns
- Reporting error at one resolution — a single point proves nothing about order.
- Calling a flat error-vs-N curve "converged" when it is actually a resolution-independent bug.
- Tolerances pulled from thin air — anchor them to the regime (→ astro-code-dev), not to whatever the run happened to produce.
- Tuning the refinement sequence until the rate looks right; pick it first, report what you get.
- Validating once and never persisting a baseline — without a stored expected-rate/invariant record, the next refactor silently regresses.

## Related
- `verification-gate` — the close-out that this validation feeds.
- `reference-parity-audit` — when there IS a reference code/analytic solution to match, not just a theoretical rate.
- `astro-code-dev` — which conservation laws and numeric thresholds apply per regime (the facts).