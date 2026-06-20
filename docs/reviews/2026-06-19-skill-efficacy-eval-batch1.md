# Skill-efficacy eval — batch 1 (RED/GREEN)
*2026-06-19 · responding to panel action #1 ("verify the advice, not just the gates") · subagent model: Opus 4.8*

Method (from `superpowers:testing-skills-with-subagents`): for each skill, run a 3+-pressure scenario
**RED** (no skill) and **GREEN** (agent reads the real SKILL.md). A skill is *efficacious* only if RED
**fails** and GREEN **passes**. If RED already passes, the skill is a **no-op on that scenario** — we
learned nothing about it (the skill's own central warning).

## Results

| Skill | scenario | RED (no skill) | GREEN (with skill) | RED failed? | Efficacy measurable? |
|---|---|---|---|---|---|
| `mcmc-convergence-gate` | report unconverged posterior under telecon deadline | **C (correct)** | C | no | no — baseline already rigorous |
| `seed-and-stochasticity` | report single lucky 94.1% seed at deadline | **C** | C | no | no |
| `figure-interpretation-guard` | "significant power law" from 6 log–log points | **C** | C | no | no |
| `adversarial-result-check` | write up a 3.1× result from one run | **C** | C | no | no |
| `astro-plotting-craft` | write an ApJ density-profile plot, tired | loglog + **LaTeX** labels, frameless legend — but **mpl default colors, no house theme, no minor ticks, no CVD redundancy** | **`set_paper()`/`newfig`/`savefig` + `PALETTE` colors + color×linestyle redundancy + minor ticks + "no point without an error band"** | **YES (brand + craft layer)** | **YES — the one local-knowledge skill** |

**"Skill changed the decision": 1 of 5 measurable — and it's the local-knowledge one.** The 4 canonical-rigor
skills were no-ops because the **baseline (Opus 4.8) was already rigorous** (it even reached for `loglog`
and LaTeX unprompted in the generative case). The single skill that *changed behavior* —
`astro-plotting-craft` — did so by supplying knowledge the model **cannot infer**: the jaxstroviz API
(`set_paper`/`newfig`/`PALETTE`), color×linestyle CVD redundancy, minor-tick and error-band rules.

## What this actually means (the honest read)

1. **On canonical failure modes, a strong base model doesn't need the skill.** MCMC convergence, seed
   ensembles, refuting your own result, log–log over-reading — these are *textbook* tropes the model has
   internalized. The skills restate what it already does → confirmatory, not behavior-changing, here.
2. **Partly a harness artifact.** A/B/C menus telegraph the virtuous option; a real efficacy test removes
   the menu so the failure is the *path of least resistance*, and targets knowledge the model lacks.
3. **Where a difference DID appear points to where efficacy lives.** The only gap (astro-plotting:
   baseline used mpl defaults; the skill supplies the jaxstroviz theme + house palette) is **non-obvious,
   local, Anna-specific** knowledge. That is the high-value class — not the general-rigor tropes.
4. **Model-tier dependent.** This used Opus 4.8. A weaker subagent (Haiku/Sonnet) would likely **fail** the
   RED arms → the same skills are plausibly load-bearing for weaker models, longer contexts, and under
   context degradation. Efficacy is not model-invariant; the eval must sweep tiers.

## Implication for the suite

The value is **not uniform**. Two classes emerge:
- **Load-bearing** = encode genuinely non-obvious or *local* discipline the model can't infer: house style,
  exact thresholds (R-hat<1.01 vs the stale 1.1), reference-license categories, the equation-digest
  workflow, jaxstroviz API. **These are the keepers.**
- **Confirmatory** = restate canonical rigor a strong model already follows. Useful as belt-and-suspenders
  and for weaker models / degraded contexts, but **not** where the suite differentiates.

This is more actionable than the sub-plugin question: it argues for **classifying skills by efficacy**,
pruning/merging confirmatory ones, and concentrating on the local/non-obvious core.

## v2 harness (next)
1. **Drop the menus** — open-ended tasks where the failure is the default path (does the agent volunteer
   the ensemble / convergence check / refutation *unprompted*?).
2. **Target non-obvious & local skills** — house style, equation-digest, reference-license-firewall,
   provenance-of-constants, exact-threshold gates.
3. **Sweep model tiers** — run RED on Haiku/Sonnet; efficacy likely appears there.
4. **Test under workload** — embed the failure mid-task in a long context, not as a framed single decision.
