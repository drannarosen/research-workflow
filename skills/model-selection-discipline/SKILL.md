---
name: model-selection-discipline
description: Use when choosing among competing models or analysis specifications — honest comparison via cross-validation / LOO / WAIC / information criteria, guarding against overfitting, double-dipping (selecting and evaluating on the same data), and the garden of forking paths (silently trying many specifications and reporting only the best). Don't use to check one model's sampler convergence (→ mcmc-convergence-gate) or its fit to data (→ predictive-checks), or to log an experiment's runs (→ experiment-tracking).
---

Comparing models is where good intentions leak into self-deception. Every extra parameter, every re-run with a tweaked specification, and every "let's just try" is a fork in the analysis. Report the model the data prefer out of sample, not the one that flattered your hypothesis — and state how many you tried.

## Discipline
- **Hold out honestly** → select on training/validation data and evaluate the winner on data untouched during selection. Selecting and scoring on the same split inflates everything.
- **Prefer predictive criteria** → LOO-CV / WAIC / k-fold over in-sample fit; penalize complexity (AIC/BIC) when cross-validation is infeasible.
- **Count the forks** → every specification tried (priors, covariates, cuts, transforms) is a comparison; a result chosen from 20 silent attempts needs that denominator stated.
- **Pre-commit where you can** → decide the comparison and metric before seeing the outcome; deviations are allowed but disclosed.
- **Report the also-rans** → which models lost and by how much; a winner in a near-tie is a weak conclusion, not a strong one.

## Anti-patterns
- Double-dipping: tuning and evaluating on the same data.
- Reporting the best of many specifications as if it were the only one run.
- A ΔAIC of 0.5 reported as "the better model."
- Adding parameters until in-sample fit improves, with no out-of-sample check.
- The garden of forking paths: data-dependent analysis choices presented as if pre-planned.

## Hard vs adaptable
- **Hard rule:** model comparison is out-of-sample (or properly complexity-penalized), and the count of specifications tried is honest.
- **Adaptable:** which criterion (LOO / WAIC / k-fold / IC) and how formal the pre-registration is scale to the stakes.

## Related
- `predictive-checks` — a selected model still has to reproduce the data.
- `mcmc-convergence-gate` — each candidate posterior must be converged before it is compared.
- `null-result-integrity` — record the specifications that didn't work; don't bury them.
- `experiment-tracking` — log every specification run so the fork count is real, not remembered.
