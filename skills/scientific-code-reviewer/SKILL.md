---
name: scientific-code-reviewer
description: Use when reviewing physics/astrophysics code that already exists — two lenses. PHYSICS: unit system consistency (CGS vs SI vs documented code units), dimensional analysis, physical bounds, conservation laws, analytic and limiting cases, AI-written formulas. NUMERICS: catastrophic cancellation (1−cos, expm1/log1p), overflow, silent non-convergence, unjustified tolerances, ill-conditioning, symplectic integrators with adaptive steps, CFL/stiffness, float32 in core physics. Don't use for JAX tracing mechanics (→ jax-code-validator), validating your own method's order during development (→ numerical-method-validation), or figures (→ figure-review).
---

# Scientific Code Reviewer

Review existing code for whether it computes the right physics, stably. Report a concise issue list
with `file:line`; expand to a per-quantity table only on request. Apply the lens(es) the change
touches and say which you skipped.

A review reports findings to the researcher. A fix that is purely numerical and leaves the physics
unchanged (`expm1`, a convergence flag, a guard) can be suggested directly. A fix that would change
the physics — a new closure, a softening choice, a boundary condition, a tolerance that decides pass
or fail, a replacement formula — is a proposal with its motivation, not a correction
(→ `researcher-in-the-loop`, `assumption-ledger`).

## Physics lens

- **Name the unit system first.** CGS, SI, or a documented code-unit system (e.g. G = 1; or M☉, pc,
  Myr with G = 4.498e-3 pc³ M☉⁻¹ Myr⁻²). Documented code units are not a defect. Flag an SI constant
  in code that claims CGS or code units (`G = 6.674e-11` next to `c = 3e10`), and an undocumented
  bare constant.
- **Dimensional analysis** on each key equation: dimensions of both sides match; "dimensionless"
  quantities really are.
- **Physical bounds**: can mass, density, temperature, or opacity go negative? Can a speed exceed c?
  Are r → 0 and other singularities handled?
- **Conservation**: energy, linear and angular momentum, mass, and problem-specific invariants
  (Jacobi integral). For simulation engines, expect an automated test asserting the invariant within
  a stated tolerance over a long integration, not an eyeballed plot.
- **Limits and references**: known analytic solutions and limiting cases (M → 0, r → ∞, t → 0) are
  cheap and belong in review; flag a new physics term that lacks its analytic-limit test. A missing
  comparison to a reference code or published result is a milestone item to note, not a review
  defect, while the code is in development (validation stages → `verification-gate`). Much real
  astrophysics (SSE fits, SCF, cluster metrics) has only semi-analytic or literature comparisons;
  accept those rather than demanding an analytic solution that doesn't exist.
- **Formulas with no derivation or citation** (often AI-written) get the dimensional and limit checks
  before anything else (→ `derivation-before-implementation`).

## Numerics lens

- **Cancellation**: `a - b` with a ≈ b; `1 - cos(x)` → `2*sin(x/2)**2`; `exp(x) - 1` → `expm1`;
  `log(1 + x)` → `log1p`; `sqrt(a**2 + b**2) - a` for a ≫ b → `b**2 / (sqrt(a**2 + b**2) + a)`.
- **Overflow / underflow**: `exp(x)` overflows float64 for x ≳ 709; float factorials overflow past
  n = 170 (use `gammaln` for ratios); CGS products like `G*M**2` can exceed float32 range. Prefer log
  space.
- **Iterations**: every solver loop has a tolerance, an iteration cap, and a reported convergence
  status. Returning the last iterate on non-convergence is a silent failure.
- **Tolerances**: a hard-coded `rtol=1e-12` needs a reason and a convergence study showing it's
  needed; tiny is not automatically good. A small residual is not a small error: the bound is
  `‖e‖/‖x‖ ≤ κ·‖r‖/‖b‖`.
- **Conditioning**: near-singular systems detected or regularized; decomposition matched to the
  matrix (Cholesky for SPD, QR/SVD for least squares).
- **Structure preservation**: an integrator claimed symplectic or time-reversible really is; a naively
  adaptive timestep breaks symplecticity and turns bounded energy error into drift; close encounters
  are regularized or softened consistently in both forces and energy diagnostics.
- **Stability**: explicit schemes respect CFL; stiff problems use implicit or IMEX methods.
- **Precision**: float64 for core physics; explicit float32 flagged unless justified; floating
  comparisons use tolerances, not `==`.

Teaching code: a naive Euler integrator in a lecture example is advisory, not a defect, unless the
code is tagged research or production.

## Output

```
## Scientific review: <file>
Unit system: <CGS | SI | code units (stated) | mixed>
Lenses: physics ✓ · numerics ✓
- L42 [physics]  no guard for r <= 0 → assert, or propose a softening (researcher's choice)
- L87 [numerics] 1 - cos(theta) at small angle → 2*sin(theta/2)**2
- Conservation: energy test exists (|ΔE/E| < 1e-8 over 1e3 t_dyn) ✓
```

## Related
- `jax-code-validator` — JAX tracing, PRNG, pytree, vmap traps.
- `numerical-method-validation` — measure a method's order and invariants against theory.
- `numerical-precision` — dtype and x64 policy.
- `equation-to-code-traceability` — connect implemented formulas to verified source rows.
- `researcher-in-the-loop` — physics-changing fixes are proposed, not applied.
