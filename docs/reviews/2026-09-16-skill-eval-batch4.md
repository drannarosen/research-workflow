# Skill-efficacy eval — batch 4 (2026-09-16 changes)

Harness: skill-creator style. Each prompt was run by independent subagents twice — **new skill** vs
**old skill** (pre-session commit `c9feaa2`) or **no skill** (for the new `model-development`). Every run
read only its assigned SKILL.md files and wrote a chat reply without running code. Grading by hand against
fixed assertions, with quoted evidence (`grading.json` per run). **One run per configuration** — this is a
direction check, not a statistical result.

| Eval | Compares | New | Baseline |
|---|---|---|---|
| 1 develop own v³ drag closure | model-development vs none | 4/4 | 3/4 |
| 2 model with hidden energy-sink gap | model-development vs none | 4/4 | 4/4 |
| 3 development numbers, next step | staged validation vs old verify skills | 4/4 | 4/4 |
| 4 eps_ff = 0.45 headline | merged adversarial-result-check vs old + plausibility-envelope | 3/3 | 3/3 |
| 5 weak NumPyro summary | bayesian-inference-gate vs old mcmc-convergence-gate | 5/5 | 4/5 |

Pass rate 100% vs 91% (+0.09); time 57 s vs 52 s; tokens 72k vs 71k.

## What it shows (honest read)
- **The underlying model already does most of this.** Without any skill it developed both researcher
  models on their own terms and found the missing turbulent-energy sink. This matches the 2026-06-19
  thesis: skills add little where the model's default is already right.
- **model-development's measurable effect is the stance at the margins.** The no-skill reply to eval 1
  asked for "an argument for why it isn't the quadratic law" and closed with falsifiable predictions and a
  discriminating test; the with-skill reply asked for nothing, labeled the closure a declared postulate,
  and ended on the next calculation. That is the premature-falsification behavior the skill targets.
- **Staged validation was not discriminated by this prompt.** The old skills also said a REBOUND
  comparison is not needed yet (no parity claim was made). The difference is tone: old framed the numbers
  as "not validated yet … checked only against energy"; new labeled them *physics-checked* and named
  external validation as owed at the milestone. Eval 6 below is the sharper follow-up.
- **The merges lost nothing on these prompts** and produced shorter replies (eval 3: 845 vs 962 words;
  eval 4: 734 vs 914).
- **bayesian-inference-gate's explicit ESS target** (≳400 total) turned "borderline" into a clear failure
  for n_eff = 180.

## Eval 6 — "Is the integrator validated enough to start the paper runs?" (2 runs per config)
New verification skills 8/8, old 7/8.
- **No run in either configuration required a reference-code (REBOUND) comparison.** Both old-skill runs
  called it optional ("would help, but it isn't required"). The behavior the staged-validation change
  targets did not reproduce from the old skill texts alone; if it happens in practice, it likely comes
  from elsewhere (session context, other skills, or the global instructions).
- **All four said "not yet / conditional" for production** and asked for cheap tides-on checks (order with
  tides on, angular-momentum and energy budgets, Hut 1981 secular rates). That is correct, not over-strict:
  the prompt's evidence never exercised the tidal term.
- **The difference is the stage framing.** Both new runs labeled the evidence *physics-checked, not
  externally validated*, one said a reference-code comparison "belongs at the end", and one explicitly
  allowed exploratory runs now. One old run never separated development checks from a later validation
  milestone (the single failed assertion).
- Caveat: the new runs treated the closed-form Hut rate comparison as external validation owed *before
  production*, which is earlier than "near the end". Reasonable for a tidal paper, but it shows "external"
  includes analytic checks the model will ask for early.

## Not tested
The new hooks (covered by 86 deterministic hook fixtures instead), figure-review, literature-workflow,
performance-measurement, and description triggering (needs `claude -p`, whose OAuth session had expired).
