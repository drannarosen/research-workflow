---
name: verification-gate
description: Evidence for claims of fixed/converged/validated; owns the validation stages. Use while running research commands whose output you will interpret, and before claiming a research task is complete, fixed, converged, validated, or parity-improving — report evidence with units, label each number's validation stage (physics-checked, analytic-checked, externally validated), translate residual norms into the physics they bound, and close out in an evidence-first format sized to the change. Owns the canonical Validation stages. Don't use for validating a numerical method against its theory (→ numerical-method-validation), the parity audit itself (→ reference-parity-audit), or recording runs across sessions (→ run-reproducibility).
---

# Verification gate

Report evidence, sized to what the result will be used for. The researcher needs to know what was
measured, at what stage of validation, and what it does and does not show.

## Validation stages (canonical; other skills cite this)

Validation is staged; don't demand the late stage early. Analytic checks are first-class and belong
in development, not at the end.

- **Physics-checked (development).** Magnitude, units, sign, scaling, and conservation trend make
  physical sense and the supervising scientist accepts the number. Self-consistency diagnostics
  (residuals, convergence with resolution, invariant drift) belong here too.
- **Analytic-checked (development; use whenever possible).** The code reproduces something known in
  closed form: an exact or manufactured solution, a limiting case (test-particle, Keplerian,
  isothermal, linear regime), a known scaling or asymptotic rate, a symmetry, or a closed-form
  secular/averaged rate. These are cheap, need no other code, and catch sign and factor errors
  early. Reach for one as soon as a module can produce the quantity, and prefer it over waiting for
  an external comparison. Each new physics term gets its analytic limit test when it is added.
- **Externally validated (at or near the end).** Before a result is published, released, handed to
  others to build on, or described as validated or matching a reference, compare against a published
  result or a reference code (→ `reference-parity-audit`). Don't require running another code (MESA,
  another N-body code) or reproducing a published figure during development; name it once as owed
  and move on.

Label the stage each reported number has reached: **physics-checked**, **analytic-checked**, or
**externally validated**, and don't present an earlier stage as a later one.

## Scale by stage

- **Exploratory, with the researcher.** Report the command, the commit, and the result against the
  prediction the run was proposed with (→ `researcher-in-the-loop`): the predicted sign, magnitude,
  or scaling next to what was measured, with units. A mismatch says which assumption or step it
  points to; don't tune until it agrees.
- **Reported or compared across sessions.** The full close-out below, recorded durably
  (→ `run-reproducibility`).
- **Released or published.** The close-out plus external validation and everything the release
  checklist asks for (→ `research-release-checklist`).

A small engineering fix (a docstring, a rename, a bug with a focused test) gets one line: what
changed, the command that proves it, and its output.

## While working

Run consequential commands (runs, solves, and edits whose output you will interpret) one at a time;
read-only exploration can be batched. Before each, state the step and the command, with expected
runtime if it is over about two minutes. After, give the key outputs with units, pass or fail
against the criterion, and whether the state shown is **solved** (converged this run), **rebuilt**
(reconstructed or cached), or **projected** (extrapolated). Run the tests that own the change, not
broad suites with no decision riding on them.

- **Translate residual norms into the physics they bound; a small residual is not a small error.**
  An L2 residual of `1e-8` on the discretized momentum equation (code units, characteristic force
  density `O(1)`) bounds each local force imbalance by `1e-8` of a dynamical force; an
  **RMS**-normalized residual of `1e-8` over N cells allows a local imbalance up to `√N·1e-8`; and
  the *solution* error is bounded only through the condition number,
  `‖e‖/‖x‖ ≤ κ(J)·‖r‖/‖b‖`. For a stiff Newton solve (κ ~ 1e8 is common in stellar structure) a
  `1e-8` residual can leave O(1) error in a poorly conditioned direction. Report the norm, the
  physical imbalance, and whether κ was estimated.
- **For high-cost runs, anchor with one representative high-precision case first**, then sweep the
  cheap approximate runs.
- A diagnostic proxy improving is not convergence, and conserved energy alone does not make a
  result correct.

## Close-out (scientific claims)

1. What changed
2. Exact command or test run, and its output
3. Solver/physics configuration and code version (integrator + settings, physics options, commit/build)
4. Measured outputs with units, dimensionally consistent (silent unit-system mixes are a top bug class)
5. Pass/fail against an explicit criterion
6. What is shown, with its validation stage and its solved / rebuilt / projected state
7. What is not yet shown, including any analytic check or external validation still owed
8. Decision: go / no-go / conditional

Say what the numbers mean physically, what they do not mean, and the current blocker if the task is
not complete. A test count ("142 passed") comes with what those tests establish. If verification was
not run, say so. A parity claim is file-backed and checkpoint-matched (→ `reference-parity-audit`);
shape resemblance is "analogy only". A landed change is done when code, tests, and the docs it
touched agree (→ `staleness-sweep`).

## Related
- `superpowers:verification-before-completion` (other plugin) — the general "run it and show the output" law; this adds the scientific layer (units, stages, residual→physics, solved/rebuilt/projected).
- `researcher-in-the-loop` — the prediction an exploratory result is reported against.
- `numerical-method-validation` — when the claim is about a numerical method's order or invariants.
- `reference-parity-audit` — the external-validation milestone for parity claims.
- `run-reproducibility` — where the close-out evidence is durably recorded.
