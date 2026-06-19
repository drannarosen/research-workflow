---
name: predictive-checks
description: Use to validate that a Bayesian or generative model actually fits — prior predictive checks before fitting (do the priors imply plausible data?) and posterior predictive checks after (does the fitted model reproduce held-out features of the real data?). Don't use to check the sampler converged (→ mcmc-convergence-gate), to compare or select among competing models (→ model-selection-discipline), to set general physical sanity bounds on a result (→ plausibility-envelope), or to report the final uncertainty (→ uncertainty-reporting-gate).
---

A converged sampler can faithfully fit a model that has nothing to do with reality. Predictive checks close that gap: simulate data from the model and compare to the world — priors before you fit, posterior after.

## Discipline
- **Prior predictive first** → sample parameters from the priors, push them through the generative model, and confirm the implied data are physically plausible. Wildly implausible prior-predictive data means the priors, not the observations, are doing the talking.
- **Posterior predictive after** → simulate replicated datasets from the posterior and compare summary statistics and distributions to the observed data.
- **Choose checks that can fail** → pick discrepancy statistics the model was *not* fit to (tails, multimodality, extremes, autocorrelation), not the mean it trivially reproduces.
- **Look, don't just score** → overlay replicated versus observed; a single Bayesian p-value hides *where* the model breaks.
- **Record misfits as findings** → a failed posterior predictive check is information about the model, not a nuisance to tune away.

## Anti-patterns
- Skipping the prior predictive check, then being surprised the prior dominates the posterior.
- Posterior predictive only on the quantity that was fit.
- Treating a Bayesian p-value near 0.5 as proof rather than the absence of one kind of misfit.
- "Fixing" a failed check by widening priors until nothing is testable.

## Hard vs adaptable
- **Hard rule:** a generative/Bayesian result is checked against simulated data — prior-predictive for the priors, posterior-predictive on a statistic that could fail.
- **Adaptable:** which discrepancy statistics and how many replications scale to the model and the claim.

## Related
- `mcmc-convergence-gate` — establishes the posterior is real before you check fit.
- `model-selection-discipline` — when several models pass, compare them honestly.
- `plausibility-envelope` — general sanity bounds independent of the generative model.
- `prior-sensitivity` — how much the result moves when the priors change.
