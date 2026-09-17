---
name: numerical-method-validation
description: Validate a method against its theory — convergence order, invariants, baselines. Use when validating a numerical method against its own theory — convergence/order-of-accuracy refinement studies, conservation/invariant checks to tolerance, oracle strategies (manufactured solutions, self-convergence, symmetry/limit checks) when no analytic truth exists, and persisting a regression baseline so verified behavior cannot silently drift. Don't use for parity against a reference implementation (→ reference-parity-audit), the general close-out format (→ verification-gate), or auditing someone else's numerics in review (→ scientific-code-reviewer).
---

Validate that a solver does what its theory claims: measured order of accuracy, conserved
invariants, and stable behavior under refinement. Use the strongest oracle available; when none
exists, combine weak oracles rather than skipping validation.

While the method is being built, refinement studies, conservation behavior, a magnitude-and-physics
check the supervisor accepts, and, whenever one exists, an analytic or manufactured solution are the
working evidence. Analytic checks are development tools, not end-of-project gates: add the analytic
limit test when you add the term. Before its results are published, released, or called validated,
the method is also checked against a published result or a reference code (→ `verification-gate`,
*Validation stages*). The oracle and refinement ratio are yours to pick and state; a tolerance that
decides pass or fail is proposed to the researcher with its physical anchor (→ `researcher-in-the-loop`).

## What a validation claim states
- **Method and claim**: the name and theoretical order p and/or the invariants it preserves (e.g. a
  4th-order symplectic integrator → p=4, bounded energy error, no secular drift).
- **Refinement sequence**: the grid spacings or timesteps used (≥3 levels, halving or fixed ratio r),
  chosen before the run and reported as measured.
- **Measured vs theory**: observed rate from successive errors `p ≈ log(e₁/e₂)/log(r)`, matching the
  claimed p within ~10%; a clean method drops to round-off, not a plateau. **Measure p in the
  asymptotic regime only**: errors above round-off and below saturation. Discard any level that has
  hit the round-off floor (it flattens p downward) and any too-coarse level not yet in the asymptotic
  band. Error at a single resolution says nothing about order.
- **Smoothness caveat**: a non-smooth solution (shocks, discontinuous ICs, slope limiters,
  `clip`/`min`/`max` kinks) caps the observed order below the scheme's formal order, and *what you
  measure depends on the norm*. Measure in L1: conservative shock-capturing gives ~1st order; a
  linear discontinuity (contact) gives only ~p/(p+1) (½ for 1st-order upwind); L∞ does not converge
  at a discontinuity at all. That is expected, not a bug; validate against the order the *solution's
  regularity and the norm* allow, and say so.
- **Adaptive-step caveat**: a symplectic integrator with a naively adaptive (state-dependent)
  timestep is no longer symplectic; bounded energy error turns into secular drift. Validate the
  bounded-error property at fixed step (or with a time-symmetric adaptive scheme) before blaming the
  integrator or the physics.
- **Invariant and tolerance**: which quantity, absolute or relative tolerance anchored to the
  physical regime rather than to what the run produced, and over what horizon (drift matters more
  than instantaneous error for long integrations).

A flat error-vs-N curve is not convergence until you have ruled out a resolution-independent bug.

## Oracle ladder (use the highest rung you can reach)
1. **Analytic solution**: exact error; the gold standard when the problem has one.
2. **Manufactured solution**: insert a chosen exact solution, derive the forcing term it requires,
   then recover it. Tests the discretization, not the physics.
3. **Richardson / self-convergence**: three resolutions, no truth needed; confirm errors shrink at
   rate r^p and Richardson-extrapolate the "true" value.
4. **Conservation as weak oracle**: an invariant holding to tolerance is necessary, not sufficient;
   a bug can conserve energy and still be wrong.
5. **Symmetry / limit checks**: time-reversibility, reflection, a known asymptotic regime (e.g.
   recover Keplerian closure or the diffusion limit). Cheap, and catches sign and factor errors.

## Planning diagnostics for a new module
Before writing a solver or sampler, list its invariants (energy, momentum, mass ≥ 0, normalization),
its regimes (small vs large N, extreme mass ratios, a < softening), and one developer plot per
invariant: `E(t)/E₀ − 1` vs t, `log error` vs `log Δt`, sampled vs analytic distribution. These plots
are what you and the supervisor judge the numbers by while the method is being built.

## Regression baselines and numerical test design
A validated method regresses silently on the next refactor unless the verified behavior is pinned
next to the test. Store, as data the test asserts against, `{expected order p, invariant + tolerance,
integration horizon, RNG seed}`: the exact thing you just showed.

- **Tolerance-based assertions for stochastic outputs.** Don't assert bit-equality on a Monte Carlo
  or sampled quantity; assert it lands within a tolerance band anchored to the physical regime, not
  to whatever this run produced. The band's width is itself a recorded baseline value.
- **Seeded determinism.** Pin the RNG seed so a stochastic test is reproducible run to run; a flaky
  numerical test is worse than none. (A seed-robust claim is a *separate* test over several seeds,
  not the regression baseline.)
- **Pin the horizon.** Drift is a long-horizon property: record the horizon the invariant tolerance
  was verified over, so a shortened test can't pass a method that drifts secularly past it.

## Related
- `verification-gate` — the close-out that this validation feeds.
- `reference-parity-audit` — at the validation milestone, when there IS a reference code or published result to match.
- `gradient-validation` — the analogous discipline for a differentiable method: validate its *gradients*, not just the forward order/conservation checked here.
- `superpowers:test-driven-development` (other plugin) — the unit-test layer beneath these baselines: write the failing test first, then the regression baseline is what it asserts against.
- `references/astro-nbody.md` — checked facts for gravitational N-body code: G per unit system, Plummer sampling and N-dependent virial scatter, self-interaction masking in JAX, Yoshida-4 vs PEFRL coefficients, force-path round-off, tree-code error.
