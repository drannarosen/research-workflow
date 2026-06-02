---
name: discriminating-experiment-design
description: Use when you have a hypothesis (or two competing ones) and need to design the minimal, cheapest experiment that would discriminate between them before writing or scoping any code — fixes the observable that differs, the expected signature under each hypothesis, the smallest run that produces it, and the accept/reject rule. Don't use to scope the CODE change that runs the experiment (→ minimal-falsifiable-slice) or for open-ended design brainstorming (→ superpowers:brainstorming).
---

Turns a hunch into a falsifiable test. Default output is a one-page experiment design, not code and not exploration — you stop at the decision rule, then hand off.

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

A 1000-body Plummer run shows energy drift. Is it the integrator's truncation order, or the softening?

| Slot | Filled in |
|------|-----------|
| **H1** | Drift is dominated by the integrator's finite order — it should scale with the timestep. |
| **H0** | Drift is dominated by the softening default (ε≈0.05·d_mean); timestep barely moves it. |
| **Discriminating observable** | \|ΔE/E\| as a function of timestep Δt, integrator order held fixed. |
| **Expected signature** | A 2nd-order symplectic scheme gives \|ΔE/E\| ∝ Δt² under H1 (halving Δt cuts drift ~4×); under H0 the curve is roughly flat in Δt and only ε moves it. |
| **Smallest run** | Same Plummer IC, short integration (≈10 dynamical times), sweep Δt over just {Δt₀, Δt₀/2, Δt₀/4} — three points fix the slope. No production-scale run needed. |
| **Decision rule** | Pre-registered: log-log slope in [1.7, 2.3] → accept H1 (integrator order). Slope < 0.5 (flat) → reject H1, drift is softening (H0). Anything between → inconclusive, redesign. |

Three timesteps and a slope settle it — far cheaper than a full convergence study, and the flat-vs-Δt² signature is one neither hypothesis can fake.

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
- "Let's run it and see what happens" — no signature, no decision rule; that's exploration, not an experiment.
- Jumping to full production scale when a 2-point sweep would already separate them.
- Designing only to show H1 works (confirmation), never the run that would expose it as wrong.

## Related
- `minimal-falsifiable-slice` — once the experiment is designed, scope the smallest code slice to run it.
- `verification-gate` — the experiment's decision rule feeds the close-out.
- `adversarial-result-check` — design the experiment to attack, not confirm, the hypothesis.