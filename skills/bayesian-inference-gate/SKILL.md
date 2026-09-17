---
name: bayesian-inference-gate
description: Use before reporting anything from Bayesian inference (MCMC/HMC/NUTS in NumPyro or Stan, nested sampling, hierarchical fits, Bayes factors) — the five gates in workflow order: prior predictive (do the priors imply plausible data?), sampler convergence (split rank-normalized R-hat < 1.01, bulk/tail ESS, divergences, BFMI, tree depth), posterior predictive (reproduce a statistic the model wasn't fit to), prior sensitivity (does the conclusion survive a defensible prior change?), and honest model comparison (PSIS-LOO with Pareto k̂, forks counted). Don't use for forward-solver convergence (→ numerical-method-validation), reporting the posterior as value ± interval (→ uncertainty-reporting-gate), or non-Bayesian seed ensembles (→ seed-and-stochasticity).
---

A converged sampler can faithfully fit a model that has nothing to do with the data, and a well-fitting model can owe its headline number to the prior. Each gate below catches a different way a posterior lies.

**Scope:** gates 2–5 apply to a posterior you will *report, compare across sessions, or act on*. While exploring a model, run the sampler freely — but no posterior number leaves the notebook as a result until they pass.

## 1. Prior predictive (before fitting)
Sample parameters from the priors, push them through the generative model, and check the implied data are physically possible. Absurd prior-predictive data means the priors, not the observations, will do the talking. A flat prior is not assumption-free — it is informative under reparameterization.

## 2. Sampler convergence (non-negotiable)
- **≥4 chains from dispersed inits** — one chain cannot diagnose itself.
- **Split, rank-normalized R-hat < 1.01** on every reported quantity. (1.05 was the older non-split criterion; it is too lax for this estimator.)
- **Bulk ESS** for point estimates, **tail ESS** for interval edges: ≳100 per chain, ≳400 total with 4 chains (Vehtari et al. 2021).
- **Zero divergences** (HMC/NUTS) — they bias exactly the tails you report. Reparameterize (non-centered), raise the target acceptance (`target_accept_prob` in NumPyro, `adapt_delta` in Stan), or shrink the step — don't ignore them.
- **BFMI** not low; **tree depth** not saturating (`max_tree_depth` in NumPyro).
- **Nested sampling** — report the evidence with its sampler uncertainty and the stopping criterion (e.g. `dlogz`); run it twice with different seeds before trusting a ΔlnZ.
- Never thin to hide autocorrelation; report ESS honestly.

## 3. Posterior predictive (does the model fit?)
Simulate replicated data from the posterior and compare to the observations on a **statistic the model was not fit to** — tails, extremes, multimodality, autocorrelation, residual structure — not the mean it trivially reproduces. Overlay replicated vs observed; a single Bayesian p-value hides *where* the model breaks. A failed check is a finding about the model, not a nuisance to tune away by widening priors.

## 4. Prior sensitivity (is it the data or the prior?)
Find the weakly constrained parameters (posterior ≈ prior). Re-run under a *defensible* alternative (uniform ↔ log-uniform, a different scale or hyperprior — not a strawman) and state the outcome: "robust to prior choice" is a result; "prior-dependent" is a caveat that travels with the number. **Bayes factors and evidences are especially prior-sensitive** (Jeffreys–Lindley): never report one without this check.

## 5. Model comparison (when several models pass)
- **PSIS-LOO** over in-sample fit; k-fold when LOO is unreliable. WAIC is dominated by PSIS-LOO and has no reliability diagnostic; AIC/BIC parameter counts are ill-defined for hierarchical models.
- **Check Pareto k̂** per data point: k̂ > 0.7 (or the sample-size-dependent threshold current ArviZ/`loo` reports) makes that point's LOO estimate unreliable — refit it exactly or switch to k-fold.
- **Report elpd differences with their SE**; within ~2 SE is not a preference. Report the also-rans.
- **Count the forks** — every prior, covariate, cut, or transform tried is a comparison; state the denominator. Fix the comparison before seeing the outcome for a claim you will publish; disclose which comparisons were exploratory.

## Related
- `uncertainty-reporting-gate` — only a posterior that passed these gates earns a reported ± interval.
- `assumption-ledger` — the prior is a load-bearing assumption; record it and its influence.
- `adversarial-result-check` — the general red-team; this is the Bayesian-specific set.
- `numerical-method-validation` — convergence of the forward model the likelihood calls.
- `experiment-tracking` — log every specification so the fork count is real.
