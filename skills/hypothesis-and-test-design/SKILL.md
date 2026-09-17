---
name: hypothesis-and-test-design
description: Use once a claim is at stake or a costly test is about to be designed (model-development's Test stance) — sharpen ONE direction into a falsifiable hypothesis with a named rival, the discriminating observable, and a kill criterion, then design the cheapest run that separates the hypotheses (expected signature under each, smallest configuration, decision rule fixed before running). Don't use while the model is still being developed or can't yet predict distinct signatures (→ model-development), to generate many candidate directions (→ research-ideation), to scope the code change that runs the test (→ minimal-falsifiable-slice), or for software design brainstorming (use superpowers brainstorming).
---

A direction is ready to *claim*, or to spend a costly run on, when it is a hypothesis you could be wrong about and a test that could tell you so. Before that point it is still being developed — use `model-development` and don't force a hypothesis card onto a model still being built.

## 1. Sharpen the hypothesis (dialogue, one question at a time)
- Restate the idea in one sentence and ask what motivates it.
- Force a falsifiable form: "X changes Y by ~Z under conditions C; if not, it's wrong."
- **Name the most credible rival** explanation — a hypothesis with no rival isn't sharp yet.
- Find the **observable** that comes out differently under hypothesis and rival.
- State the **prediction** (with rough effect size) and the **kill criterion**.

```text
hypothesis:       <one falsifiable sentence>
regime/scope:     <where it is claimed to hold>
rival:            <the credible alternative>
observable:       <what differs between them>
prediction:       <expected signature, rough size>
kill criterion:   <result that refutes it>
```

## 2. Design the discriminating test
| Slot | Specify |
|---|---|
| **Expected signature** | What you'd see under each hypothesis, quantified — sign, slope, scaling, order. If both predict the same number, pick another observable. |
| **Smallest run** | Shortest integration, fewest particles/cells, coarsest grid, one parameter swept over ≥2–3 points. Prefer an analytic or scaling check if it separates them. |
| **Decision rule** | Accept and reject thresholds written down **before** running. |

**Worked example.** A 1000-body Plummer run with fixed-step 2nd-order leapfrog reports |ΔE/E| ≈ 1e-3. *H1:* integrator truncation. *H0:* the energy diagnostic uses the unsoftened potential while forces use the softened kernel — a bookkeeping offset. *Observable:* max |ΔE/E| over ~10 crossing times vs Δt ∈ {Δt₀, Δt₀/2, Δt₀/4}. *Signature:* slope ≈ 2 under H1; flat under H0, and the offset vanishes when E is recomputed with the softened kernel (no new run needed). *Rule:* slope in [1.7, 2.3] → H1; slope < 0.5 and offset vanishes → H0; otherwise redesign. Use the maximum over the run — a symplectic integrator's energy error is bounded and oscillatory.

## Rules
- **Discriminate, don't confirm** — a test only H1 can pass proves nothing.
- **Vary one thing** the hypotheses disagree on; hold the rest fixed.
- **The decision rule is fixed in advance.** Moving thresholds after seeing data turns a test into confirmation.
- **Not yet?** If the signature rows can't be filled, the model isn't specified enough — go back to `model-development` for the calculation that makes it predict something.

## Anti-patterns
- "Explore the relationship between …" offered as the hypothesis itself.
- A run both hypotheses survive; confirmation-only predictions.
- Jumping to production scale when a three-point sweep would separate them.

## Related
- `model-development` — Explore/Develop before a claim is at stake; this is its Test stance.
- `research-ideation` — generate and triage directions before sharpening one.
- `minimal-falsifiable-slice` — scope the smallest code change that runs the test.
- `literature-workflow` — check the sharpened hypothesis isn't already answered.
- `verification-gate` — the decision rule feeds the close-out.
