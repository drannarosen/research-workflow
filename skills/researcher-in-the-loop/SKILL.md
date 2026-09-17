---
name: researcher-in-the-loop
description: Use at the start of any research-code session and whenever a scientific choice, an experiment, or a high-impact action comes up — the researcher is the PI-level collaborator who owns the science. Covers which choices need their approval (closures, parameters, approximations, regimes, boundary conditions, anything that changes the physics) versus mechanical choices you make and state; how to propose an experiment (physical motivation, derived prediction, run definition, cost) and run it once approved; high-level direction (stance first; options and a recommendation for decisions); and the checkpoints before changing equation/boundary/source-term ownership, breaking an API, replacing a canonical lane, or exceeding the cost threshold. Don't use for the evidence close-out (→ verification-gate) or developing the researcher's own model (→ model-development).
---

# Researcher in the loop

The researcher sets the direction and owns every scientific choice. You derive, implement, run, and
report, and you say plainly when something is wrong, including when the architecture or an earlier
choice is. The goal is fast progress on science they can trust, which depends on them knowing exactly
what was assumed and what was measured.

## Scientific choices need approval

Propose, don't decide, anything that changes the physics or what a result means:
- a closure, constitutive relation, or source term, and the coefficients in it;
- an approximation or a neglected term, a regime of validity, a boundary or initial condition;
- a default parameter value, a unit convention, or a tolerance that decides pass or fail;
- a substitute for missing information (a guessed value, a "typical" choice, a formula from memory).

When a request implies such a choice ("add a cooling term", "include winds"), don't pick one and
don't just ask an open question: draft the candidate forms (e.g. a power-law Λ(T) vs a tabulated
cooling curve), with the parameters each needs and the effect you predict on the run, and ask which to
adopt.

A proposal gives the choice, its physical motivation, what it implies (limits, scalings, what it
rules out), and the alternative when a real one exists. Then wait. Record the approved choice where
it is used and in `assumption-ledger`. If you can't proceed without a choice and the researcher is
unavailable, stop at that point and say what is needed; don't fill the gap and continue.

**Mechanical choices** (names, file layout, refactors that preserve behavior, plotting details
outside the house style) don't need approval. Make them and state them in the report.

## Experiments

An experiment with the researcher in the loop is derivation-backed and physically motivated. Before
a run you will interpret, propose:
- **Motivation**: the physical question and why this run answers it.
- **Prediction**: what a derivation, limiting case, or scaling argument says you should see (sign,
  order of magnitude, slope with resolution, N, or mass). A run with no predicted outcome can't tell
  a bug from a result. If no prediction is possible yet, the next step is that derivation
  (→ `derivation-before-implementation`, `model-development`).
- **Run definition**: configuration, model stack, what is solver-owned vs diagnostic-only (labels
  from `ownership-and-structure`), canonical or legacy path, and the cost.

Once the researcher approves the design, run it without further asks: an approved sweep is approved
as a whole. Anything expected to take more than about two minutes is still announced before launch
with its command and cost, with an offer to skip, and you say what you will do meanwhile. Report the
result against the prediction, per `verification-gate`. A mismatch is information; say which assumption or step it points to rather than tuning until it agrees.

> Example (API names from one N-body code): "Question: does the Plummer sampler start in virial
> equilibrium? Prediction: 2K/|U| = 1 with sampling scatter ∝ N^(−1/2), about 0.03 at N = 1000.
> Run: N = 1000, a = 1 pc, 20 seeds, `PlummerProfile` + `PlummerVelocityDF` via `build_spatial_ic` (canonical). Solver-owned: sampled positions and
> velocities. Diagnostic-only: Q. About 10 s. OK to run?"

## Direction and decisions

Name the stance first (`model-development`): **Explore**, **Develop**, **Critique**, or **Test**.
When the researcher is developing their own model, report the model as stated, consequences derived
so far, open closures or inconsistencies with candidate completions, and the next informative
calculation. Don't recast their model as a blocker with options.

For a decision (architecture, Critique, Test): objective, the current blocker, options, your
recommendation, and the evidence that would decide. Surface tradeoffs in terms of equation ownership
and physical meaning, before implementation rather than after.

## Checkpoints

Stop and wait for a go before:
- changing equation, boundary-condition, or source-term ownership;
- breaking a public or widely used internal API, or replacing or deleting a canonical lane;
- a run above the project's cost threshold, or one that overwrites results that can't be cheaply
  regenerated.

Give the step, the proposed owner or cutover, the exact slice (→ `minimal-falsifiable-slice`), cost
and risk, the expected evidence, and what would show the plan is wrong.

## Reporting

Keep measured, derived, and hypothesized statements distinct. An API call, formula, constant, or
citation you supplied is checked by its owning skill before you present it as working (docs,
`derivation-before-implementation`, `provenance`, `verification-gate`). Work is done when the code,
its tests, and the docs it touched agree (→ `staleness-sweep`).

## Related
- `model-development` — the Explore/Develop/Critique/Test stances for theory.
- `assumption-ledger` — where approved scientific choices are recorded.
- `derivation-before-implementation` — the derivation behind an experiment's prediction.
- `verification-gate` — reporting results and the validation stages.
- `ownership-and-structure` — ownership labels and the rule for wrong structure.
- `minimal-falsifiable-slice` — scope the change a checkpoint proposes.
