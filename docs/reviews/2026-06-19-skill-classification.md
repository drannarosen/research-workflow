# Skill classification by efficacy mode — all 70
*2026-06-19 · applies the eval finding (efficacy ∝ locality × counter-instinctuality) to the full suite.*
*Judgment-based prediction anchored on 7 empirically tested skills (✓tested). A hypothesis for v3 to validate, not a verdict.*

## The four modes

Applying the rubric to all 70, "counter-instinctuality" splits into two distinct mechanisms, giving
**three differentiating modes** + one confirmatory bucket:

- **1a — Local knowledge** the model *cannot* infer (project/house APIs, exact non-obvious thresholds, domain syntax). High efficacy. `astro-plotting-craft` ✓tested.
- **1b — Counter-stance**: the rigorous move *opposes* the model's default helpful instinct. High efficacy. `correct-cutover` ✓tested (model defaults to a compat shim).
- **1c — Omission-discipline**: good practice the model *knows but skips* unprompted (record provenance, pin env, log runs). **Predicted high efficacy via omission — the suite's biggest UNTESTED bet.**
- **2 — Confirmatory**: restates canonical rigor the model already *does* by default. ≈0 lift even at Haiku. ✗tested: `seed-and-stochasticity`, `adversarial-result-check`, `figure-interpretation-guard`, `reference-license-firewall` (core reflex).

## Assignment (by mode)

**1a — Local knowledge (~13) — keep & invest; the moat the model can't replicate**
`astro-plotting-craft` ✓ · `docs-writing-voice` · `myst-expert` · `myst-ci` · `interactive-figures` · `mystmd-plugin-dev` · `plot-craft-reviewer` · `jax-performance` · `jax-code-validator` · `gradient-validation` · `reference-parity-audit` (lenses) · `publication-figure-validator` · the `reference-license-firewall` *category framework*.

**1b — Counter-stance (~10) — keep & invest; where the skill overrides a wrong instinct**
`correct-cutover` ✓ · `ownership-and-structure` · `minimal-falsifiable-slice` · `derivation-before-implementation` · `no-silent-except` (+hook) · `no-stub-when-done` (+hook) · `null-result-integrity` · `evidence-first-execution` (+hook) · `verification-gate` · `researcher-in-the-loop` · `high-impact-checkpoint` · `discriminating-experiment-design` · `research-brainstorming`.

**1c — Omission-discipline (~14) — TEST FIRST in v3; predicted-but-unproven**
`provenance-of-constants` · `experiment-tracking` · `data-provenance` (+hook) · `decision-log-and-commits` · `assumption-ledger` · `staleness-sweep` · `reproducible-environment-contract` · `artifact-first-reproducibility` · `software-citation` · `research-release-checklist` · `data-management-plan` · `cluster-run-contract` · `profiling-discipline` · `scaling-validation` · `no-secrets-in-git` (+hook).
*Why untested matters: these are exactly the things a capable model omits under deadline — the omission failure mode v2's menus couldn't catch. If they fire, they're a large slice of the suite's real value.*

**Equation-critical workflow (4) — 1b/1c hybrid (process the model wouldn't follow unprompted) — keep**
`pdf-equation-extraction` · `equation-to-code-traceability` · `equation-errata-ledger` · (`reference-license-firewall` listed in 1a).

**Literature/Ideate process (4) — mild 1b, keep**
`research-ideation` · `prior-art-check` · `reading-notes-discipline` · `related-work-map`.

**2 — Confirmatory (~15) — merge/compress, or promote the gate to a HOOK**
`adversarial-result-check` ✗ · `seed-and-stochasticity` ✗ · `figure-interpretation-guard` ✗ · `ai-self-distrust` · `plausibility-envelope` · `systematic-error-hunting` · `uncertainty-reporting-gate` · `prior-sensitivity` · `numerical-method-validation` · `predictive-checks` · `model-selection-discipline` · `testing-strategist` · `scientific-code-reviewer` · `numerical-methods-auditor` · `error-handling-reviewer` · `code-craft-reviewer` · `benchmark-generator` · `plot-faithfulness-inspector` · `plot-design-inspector`.
*`mcmc-convergence-gate` ✓marginal sits here on the action axis but carries a local nugget (R-hat<1.01 modern threshold) — best resolved as a **hook**, not advisory text.*

## Counts (predicted)
- **Differentiating (1a+1b+1c+process): ~45** — the model can't reproduce these unprompted (knowledge, stance, or omission).
- **Confirmatory (Tier 2): ~15–19** — the model already does it; advisory text adds ~0.

## What this reframes
The "only 2 of 7 tested hits" headline **understated** the suite: the no-ops were all sampled from the *confirmatory* bucket (canonical rigor) — the worst case. The bulk of the suite is differentiating via **locality, counter-stance, or omission**. The genuinely-redundant slice is the ~15 confirmatory rigor-restatements.

## Actions
1. **Confirmatory (~15):** compress/merge; **promote the load-bearing gates to deterministic hooks** (panel #2) — `mcmc-convergence-gate` (posterior summary without R-hat/ESS → block) is the prototype. A hook is "enforce what the model usually does anyway, for when it doesn't."
2. **Omission-discipline (~14):** **this is the v3 priority** — author scenarios where the model omits provenance/env-pinning/logging under realistic workload. If they fire, they're proven value; if they don't, they merge too.
3. **Local + counter-stance (~23):** the proven/strong core — keep & invest; this is the suite's moat and the argument *against* shattering it into sub-plugins.

## Caveat
1a is partly tested (1 skill); 1b partly tested (1 skill); **1c is entirely predicted.** The classification is a prioritized hypothesis, not a measured result. v3 should test 1c first (largest untested mass), then a confirmatory-bucket spot-check to confirm the merge list.
