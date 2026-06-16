---
name: prior-sensitivity
description: Use when a conclusion comes from Bayesian inference — MCMC/nested-sampling posteriors, model comparison (Bayes factors/evidence), hierarchical fits — gate that the conclusion survives a reasonable change of prior, so you report a result driven by the data rather than an artifact of the prior. Don't use for general "is this result an artifact" red-teaming (→ adversarial-result-check), recording the prior as a load-bearing assumption (→ assumption-ledger), or reporting the posterior's width (→ uncertainty-reporting-gate).
---

A posterior is data filtered through a prior; a conclusion that flips when you nudge the prior is a statement about the prior, not the universe. When a result rests on Bayesian inference, test whether it is prior-driven: re-run under a different *reasonable* prior and see whether the conclusion holds. Especially where the data are weak, the prior can quietly do the work you are crediting to the data.

## Sensitivity check
- **Find the influential priors** → which parameters are weakly constrained (posterior ≈ prior)? Those are where the prior, not the data, is steering the answer.
- **Re-run under a defensible alternative** → swap uniform for Jeffreys/log-uniform, widen or narrow a scale, change a hyperprior — within what's reasonable, not a strawman — and compare the conclusion.
- **Report the dependence, not just the headline** → state whether the conclusion is robust to prior choice or holds only under the chosen one. "Robust to prior" is a result; "prior-dependent" is a caveat that must travel with the number.
- **Check the prior predictive** → does the prior imply absurd data *before* fitting? An unphysical prior predictive is a red flag regardless of the posterior.
- **Treat model comparison with extra care** → Bayes factors and evidences are notoriously prior-sensitive (Jeffreys–Lindley); never report one without a prior-sensitivity note.

## Anti-patterns
- A headline constraint on a weakly-informed parameter, with no check that the data (not the prior) produced it.
- Reporting a Bayes factor or evidence ratio with no note on its prior dependence.
- Choosing the prior that yields the desired posterior, then presenting it as the natural choice.
- Treating "uninformative" priors as assumption-free — a flat prior is informative under reparametrization.

## Hard vs adaptable
- **Hard rule:** a Bayesian conclusion ships with its prior-sensitivity established — robust, or explicitly caveated as prior-dependent. An unchecked prior is an unowned assumption steering the result.
- **Adaptable:** how many alternative priors and which — scale to how weakly the data constrain the quantity and how much rides on the conclusion.

This tests robustness *to the prior specifically*; general "could this be an artifact?" red-teaming is `adversarial-result-check`, and the prior itself belongs in the `assumption-ledger`.

## Related
- `adversarial-result-check` — prior-sensitivity is the Bayesian-specific instance of attacking your own result.
- `assumption-ledger` — the prior is a load-bearing assumption; record it and its influence.
- `uncertainty-reporting-gate` — reports the posterior *width*; this checks the posterior's *location* isn't a prior artifact.
- `seed-and-stochasticity` — sampler draws are stochastic too; confirm the posterior is converged, not a chain fluctuation.
