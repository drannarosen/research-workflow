# Skill-efficacy eval — batch 2 (v2 harness) + cross-batch synthesis
*2026-06-19 · v2 fixes v1's confounds: no menus (failure = path of least resistance), weak-tier sweep (Haiku), local/counter-instinctual targets, pre-registered binary failure signals.*

## v2 results

| Cell | Skill | model | RED (no skill) | GREEN (skill) | RED failed? | Efficacy |
|---|---|---|---|---|---|---|
| A1 | `mcmc-convergence-gate` | Haiku | flagged R-hat/ESS/divergences; offered bare number only "if you must" | withheld outright, cited R-hat<1.01 | **no** (flagged unprompted) | marginal (crisper) |
| A2 | `seed-and-stochasticity` | Haiku | wrote hedged para, "not publishable as is" | refused single-seed, demanded ensemble | **no** | marginal |
| A3 | `adversarial-result-check` | Haiku | declined to draft, asked for info | full refutation framework / attack lanes | **no** | marginal |
| B1 | `reference-license-firewall` | Opus | **refused GPL→BSD unprompted**, proposed clean-room | refused + category table + clean-room | **no** | structure only |
| B2 | `correct-cutover` | Opus | **recommended a back-compat `.velocities` shim** | **refused scaffolding, cited the rule, clean cutover** | **YES** | **YES (clean)** |

**v2: 1 of 5 clean efficacy** — `correct-cutover`. The Haiku tier-sweep did **not** show rescue (even Haiku flagged the canonical rigor); license-firewall did **not** fail on Opus (GPL incompatibility is internalized).

## Cross-batch synthesis (v1 + v2, 7 distinct skills)

**Skills that demonstrably changed behavior:**
- `astro-plotting-craft` (v1) — encodes **local knowledge the model can't have** (jaxstroviz API, house palette, CVD redundancy).
- `correct-cutover` (v2) — encodes a **stance that opposes the model's default instinct** (clean cutover vs. the conventional compat-shim reflex).

**Skills that were no-ops (model already complies, both tiers):** `mcmc-convergence-gate`, `seed-and-stochasticity`, `adversarial-result-check`, `figure-interpretation-guard`, `reference-license-firewall` (core "GPL bad" reflex).

## The finding: efficacy is predicted by two factors

1. **Locality** — does the skill encode knowledge the model *cannot* have (project/house conventions, package APIs, exact local thresholds)?
2. **Counter-instinctuality** — does the skill's stance *oppose* the model's default helpful instinct (structural-correctness-over-compatibility; delete-don't-shim; null-result-integrity over a clean story)?

Skills that merely **restate canonical rigor** the model has already internalized (convergence, seed ensembles, refute-your-result, GPL incompatibility, log-log over-reading) produce ≈0 behavioral lift **even at the Haiku tier**. Their value is decisiveness/crispness, teaching, and the *deterministic hooks* behind them — not the advisory text.

## Classification rubric for the 70 skills

- **Tier 1 — differentiating (keep & invest):** local-knowledge + counter-instinctual. e.g. `astro-plotting-craft`/house-style, `correct-cutover`, `ownership-and-structure`, `equation-digest` workflow, the `reference-license-firewall` *category framework* (the structure, not "GPL bad"), `provenance-of-constants`, domain lenses, `docs-writing-voice`, exact-threshold gates.
- **Tier 2 — confirmatory:** rigor-restatements the model already follows. Compress/merge candidates — **or promote the high-value ones to deterministic hooks** (panel action #2), since a hook is exactly "enforce the thing the model usually does anyway, for the times it doesn't."

This empirically answers both open questions: **which skills to prune/merge** (Tier 2) and **which to harden into hooks** (the load-bearing Tier-2 gates).

## Honest limits
1. Small sample (7 of 70); needs systematic sampling.
2. "No clean RED fail" can mean genuine rigor *or* under-tempting scenarios — B2 proves the method finds clean fails when the scenario hits a real instinct-divergence. Design scenarios at each skill's counter-instinctual core.
3. Single-decision, short-context — real drift happens over long multi-step work (turn 40, not turn 1). Untested.
4. B2 GREEN explored the repo more than RED; the shim-vs-no-shim criterion still separates cleanly.
5. Tiers tested: Haiku + Opus. Not tested: very long contexts, adversarial users, rigor degraded by other means.

## v3 (full harness)
Systematic skill sample; scenarios authored at each skill's **counter-instinctual / local core**; embed the failure mid-workload in long context; blind judge against pre-registered signals; report efficacy × tier. Skills that can't be made to fail RED under a fair counter-instinctual scenario are confirmatory by definition → prune or convert to hooks.
