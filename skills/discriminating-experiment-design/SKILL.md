---
name: discriminating-experiment-design
description: Use when you have a hypothesis (or two competing ones) and need to design the minimal, cheapest experiment that would discriminate between them before writing or scoping any code — fixes the observable that differs, the expected signature under each hypothesis, the smallest run that produces it, and the accept/reject rule. Don't use while the model is still being developed and cannot yet yield distinct signatures (→ model-development: pick the next exploratory calculation), to scope the CODE change that runs the experiment (→ minimal-falsifiable-slice) or for open-ended design brainstorming (→ superpowers:brainstorming).
---

Turns a hunch into a falsifiable test. Default output is a one-page experiment design, not code and not exploration — you stop at the decision rule, then hand off.

**Not yet?** If you cannot fill the signature rows because the model is not specified enough to predict anything distinct, don't force the table. Go back to `model-development` and run the calculation (scaling, limit, nondimensionalization, exploratory integration) that makes the model predict something. Exploration is a legitimate step; it just isn't an experiment.

## The design (fill every row before any code is written)

| Slot | Must specify |
|------|--------------|
| **Hypothesis H1** | The claim, stated so it can be wrong (e.g. "energy drift is from the integrator, not the softening"). |
| **Alternative H0** | The rival it's tested *against*. "H1 is true" is not enough — name what else could produce the same surface symptom. |
| **Discriminating observable** | The one quantity that differs between H1 and H0. If both predict the same number, it discriminates nothing — pick another. |
| **Expected signature** | What you'd see under H1 *vs* under H0, quantified (sign, slope, scaling, order — e.g. "error ∝ Δt² under H1, flat under H0"). |
| **Smallest run** | The cheapest configuration that still produces the signature: shortest integration, fewest particles/cells, coarsest grid, one parameter swept over ≥2 points. |
| **Decision rule** | The result that accepts H1 and the result that rejects it, fixed *now* — not after seeing the data. |

## Worked example (all six slots)

A 1000-body Plummer run with a fixed-step 2nd-order leapfrog reports |ΔE/E| ≈ 1e-3. Integrator truncation, or a diagnostic that doesn't match the dynamics?

| Slot | Filled in |
|------|-----------|
| **H1** | The error is integrator truncation — it scales with the timestep. |
| **H0** | The energy diagnostic uses the unsoftened potential while forces use the softened kernel, so the "error" is a bookkeeping offset independent of Δt. |
| **Discriminating observable** | max \|ΔE/E\| over the run as a function of Δt, softening and integrator held fixed. |
| **Expected signature** | Leapfrog is 2nd order: under H1 halving Δt cuts the error ~4× (log-log slope ≈ 2); under H0 the curve is flat in Δt and the offset vanishes when E is recomputed with the softened kernel. |
| **Smallest run** | Same IC, ~10 crossing times, Δt ∈ {Δt₀, Δt₀/2, Δt₀/4} — three points fix the slope; the H0 check needs no new run at all. |
| **Decision rule** | Pre-registered: slope in [1.7, 2.3] → accept H1. Slope < 0.5 (flat) and the offset disappears with the softened diagnostic → accept H0. Anything else → inconclusive, redesign. |

A symplectic integrator's energy error is bounded and oscillatory, so compare the *maximum* over the run, not the endpoint. Three timesteps and a slope settle it — far cheaper than a convergence study, and a Δt² slope versus a flat offset is a signature neither hypothesis can fake.

## Rules

- **Discriminate, don't confirm.** A test only H1 can pass proves nothing; design the run where H1 and H0 diverge most sharply. If you can't state an outcome that kills H1, you don't have an experiment yet.
- **Cheapest signature wins.** Prefer a scaling/sign/ordering check (resolution sweep, conservation slope, symmetry) over a high-fidelity production run — these discriminate at a fraction of the cost.
- **Vary one thing.** Sweep the single parameter the hypotheses disagree on; hold the rest fixed so the signature is unambiguous.
- **Decision rule is pre-registered.** Write accept/reject thresholds before running. A rule invented after seeing results confirms, it doesn't test.

## Hard vs adaptable

- **Non-negotiable:** the pre-registered decision rule. Accept/reject thresholds are fixed *before* the run, in writing. Move them after seeing data and the experiment becomes confirmation.
- **Adaptable scaffold:** the six-slot table. Fold slots together or rename them for the task; what must survive is *one observable that diverges between hypotheses + a rule fixed in advance*.

## Anti-patterns

- A run both hypotheses survive — measures the wrong observable.
- "Let's run it and see what happens" *presented as a test of a claim* — no signature, no decision rule; that's exploration (fine in `model-development`), not an experiment.
- Jumping to full production scale when a 2-point sweep would already separate them.
- Designing only to show H1 works (confirmation), never the run that would expose it as wrong.

## Related
- `model-development` — where the model gets specified enough to predict distinct signatures.
- `minimal-falsifiable-slice` — once the experiment is designed, scope the smallest code slice to run it.
- `verification-gate` — the experiment's decision rule feeds the close-out.
- `adversarial-result-check` — design the experiment to attack, not confirm, the hypothesis.