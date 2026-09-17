# Skill routing test — 2026-09-16

**Question:** given the installed skill list (research-workflow at 54 skills, plus every other enabled
plugin and global skill), does a realistic request route to the right skill?

**Method:** 12 independent subagents. Each received one realistic prompt, was told to invoke the single most
appropriate skill (or none), and to do no work. Results were read from the **actual `Skill` tool calls**
in each transcript, not the agents' self-reports. `claude -p` was unavailable (expired OAuth), so
skill-creator's description-optimization loop could not run.

| # | Request (abridged) | Expected | Invoked |
|---|---|---|---|
| t01 | my own v³ drag closure — what does it imply? | model-development | model-development ✓ |
| t02 | Gaia DR4 wide binaries — brainstorm directions | research-ideation | research-ideation ✓ |
| t03 | check fig 3 before ApJ submission | figure-review / astro-plotting-craft | figure-review ✓ |
| t04 | eps_ff = 0.45 as tonight's headline | adversarial-result-check | adversarial-result-check ✓ |
| t05 | NumPyro r_hat 1.03, 12 divergences, report it? | bayesian-inference-gate | bayesian-inference-gate ✓ |
| t06 | review pefrl.py for jit/PRNG/vmap problems | jax-code-validator | jax-code-validator ✓ |
| t07 | integrator validated enough for paper runs? | verification-gate / numerical-method-validation | numerical-method-validation ✓ |
| t08 | stellax vs MESA at ZAMS/TAMS/RGB tip for release | reference-parity-audit | reference-parity-audit ✓ |
| t09 | novelty check: differentiable tidal evolution | literature-workflow | literature-workflow ✓ |
| t10 | jax.grad NaN at r=0, forward finite | gradient-validation | gradient-validation ✓ |
| t11 | explain virial theorem for ASTR201 (negative) | none | none ✓ |
| t12 | fix a README typo (negative) | none | none ✓ |

**12/12 routed correctly**, including the merged skills (figure-review, bayesian-inference-gate,
literature-workflow, adversarial-result-check) against competing global skills.

**Limits.** The agents were told to consider skills, so this measures *which* skill wins, not whether the
model reaches for one unprompted in a normal session — that needs `claude -p` trigger runs. One run per
prompt. The retired `astro-code-review` and `myst` plugins are installed but disabled, so they did not compete.

## Post-merge check (ADR-0015, 54 → 43) — pre-restart, so NOT a test of the new descriptions
Ten prompts aimed at each merged skill were run after the merge, but subagents inherit the session's
skill list, which was loaded before the reinstall; every call resolved to a **pre-merge** skill. What it
does show is that each request landed on exactly the skills now merged into the intended target:

| # | Request (abridged) | Invoked (old list) | Now lives in |
|---|---|---|---|
| r01 | log a 40-point sweep for later comparison | experiment-tracking | run-reproducibility |
| r02 | OOM-killed SLURM job, use partial snapshots? | cluster-run-contract | run-reproducibility |
| r03 | hardcode Tout fit coefficients + load a Gaia file | provenance-of-constants, data-provenance | provenance |
| r04 | release gravax so it's citable at the paper version | software-citation | research-release-checklist |
| r05 | make the tidal-heating claim falsifiable + cheapest run | research-brainstorming, discriminating-experiment-design | hypothesis-and-test-design |
| r06 | move eps_grav into the Newton residual + change API | high-impact-checkpoint | researcher-in-the-loop |
| r07 | deploy MyST docs to Pages, assets 404 | myst-ci | myst-expert |
| r08 | interactive Plotly HR diagram on a MyST page | interactive-figures | mystmd-plugin-dev |
| r09 | 3 seeds → what number and error bar? | uncertainty-reporting-gate | uncertainty-reporting-gate |
| r10 | run the check, show numbers, close out | verification-gate | verification-gate |

**To do after restarting Claude Code:** re-run r01–r10 (plus t01–t12 above) against the 43-skill list.
