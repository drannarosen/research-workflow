---
name: verification-gate
description: Use while running research commands whose output you will interpret, and before claiming a research task is complete, fixed, converged, validated, or parity-improving — report evidence with units, label each number's validation stage (physics-checked, analytic-checked, externally validated), translate residual norms into the physics they bound, and close out in an evidence-first format sized to the change. Owns the canonical Validation stages. Don't use for validating a numerical method against its theory (→ numerical-method-validation), the parity audit itself (→ reference-parity-audit), or recording runs across sessions (→ run-reproducibility).
---

# Verification Gate

Evidence first, from the first consequential command to the close-out. Sized to the change: a scientific claim (a result, a convergence or parity statement, a physics change) gets the full close-out; a small engineering fix (a docstring, a rename, a bug with a focused test) gets one line — what changed, the command that proves it, and its output.

## Validation stages (canonical — other skills cite this)

Validation is staged; don't demand the late stage early. Analytic checks are first-class and belong in development, not at the end.

- **Physics-checked (development).** Magnitude, units, sign, scaling, and conservation trend make physical sense and the supervising scientist accepts the number. Self-consistency diagnostics (residuals, convergence with resolution, invariant drift) belong here too.
- **Analytic-checked (development — use whenever possible).** The code reproduces something known in closed form: an exact or manufactured solution, a limiting case (test-particle, Keplerian, isothermal, linear regime), a known scaling or asymptotic rate, a symmetry, or a closed-form secular/averaged rate. These are cheap, need no other code, and catch sign and factor errors early — reach for one as soon as a module can produce the quantity, and prefer it over waiting for an external comparison. Each new physics term should get its analytic limit test when it is added.
- **Externally validated (at or near the end).** Before a result is published, released, handed to others to build on, or described as validated or matching a reference, compare against a published result or a reference code (→ `reference-parity-audit`). Do **not** require running another code (MESA, another N-body code) or reproducing a published figure during development; name it once as owed and move on.

Label which stage a reported number has reached: **physics-checked**, **analytic-checked**, or **externally validated**. Never present an earlier stage as a later one.

## While working

One *consequential* command at a time — runs, solves, and edits whose output you will interpret; read-only exploration can be batched. For each: before, say the step and the exact command (and expected runtime if over ~2 minutes); after, give the key outputs **with units**, pass/fail against the criterion, and whether the state shown is **solved** (converged this run), **rebuilt** (reconstructed/cached), or **projected** (extrapolated).

- **Translate residual norms into the physics they bound — a small residual is not a small error.** An L2 residual of `1e-8` on the discretized momentum equation (code units, characteristic force density `O(1)`) bounds each local force imbalance by `1e-8` of a dynamical force; an **RMS**-normalized residual of `1e-8` over N cells allows a local imbalance up to `√N·1e-8`; and the *solution* error is bounded only through the condition number, `‖e‖/‖x‖ ≤ κ(J)·‖r‖/‖b‖`. For a stiff Newton solve (κ ~ 1e8 is common in stellar structure) a `1e-8` residual can leave O(1) error in a poorly conditioned direction. Report the norm, the physical imbalance, and whether κ was estimated.
- **For high-cost runs, anchor with one representative high-precision case first**, then sweep the cheap approximate runs.

## Close-out (scientific claims)

1. What changed
2. Exact command or test run
3. Solver/physics configuration and code version (integrator + settings, physics options, commit/build)
4. Measured outputs **with units**
5. Pass/fail against an explicit criterion
6. What is proven — with its validation stage and its solved / rebuilt / projected state
7. What is not yet proven — including any analytic check or external validation still owed
8. Decision: go / no-go / conditional

Say what the numbers mean physically, what they do not mean, and the current blocker if the task is not complete.

## Rules

1. No success claims ("works", "fixed", "converged", "parity") without the command and its output in the same message. If verification was not run, say so plainly.
2. No bare test counts ("142 passed") without their scientific meaning.
3. Every quantity carries units and the result is dimensionally consistent — silent unit-system mixes are a top bug class.
4. Self-consistency or physics-checked only is a legitimate development state — label it, don't inflate it.
5. A parity claim must be file-backed and checkpoint-matched (→ `reference-parity-audit`); shape resemblance is "analogy only".

## Anti-patterns
- "Converged" when only a diagnostic proxy improved; "energy is conserved, so it's correct".
- Reporting a solver-space norm as if it were direct physical truth.
- Batch-running broad suites with no decision riding on them.

## Related
- `superpowers:verification-before-completion` (other plugin) — the general "run it and show the output" law; this adds the scientific layer (units, stages, residual→physics, solved/rebuilt/projected).
- `numerical-method-validation` — when the claim is about a numerical method's order or invariants.
- `reference-parity-audit` — the external-validation milestone for parity claims.
- `run-reproducibility` — where the close-out evidence is durably recorded.
