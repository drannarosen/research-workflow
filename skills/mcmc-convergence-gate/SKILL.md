---
name: mcmc-convergence-gate
description: Use before trusting any MCMC/HMC/NUTS posterior — gate that the sampler actually converged: R-hat, bulk and tail ESS, divergent transitions, BFMI/energy, tree-depth saturation, and multi-chain agreement, judged before any posterior summary (mean, quantile, credible interval) is reported. Don't use for forward-simulation numerical convergence (→ numerical-method-validation), reporting the converged posterior as value ± credible interval (→ uncertainty-reporting-gate), the seed-to-seed spread of a non-MCMC stochastic run (→ seed-and-stochasticity), or whether the model itself fits the data (→ predictive-checks).
---

A posterior summary from an unconverged sampler is a number with no meaning. Convergence diagnostics are not decoration — they are the precondition for reading any quantile, mean, or credible interval. Run several chains and clear every diagnostic before a posterior summary is allowed to leave the notebook.

## Gate
- **Run ≥4 chains from dispersed inits** → a single chain cannot diagnose itself; between-chain disagreement is the signal.
- **R-hat < 1.01** → split, rank-normalized, on every reported quantity, not just the mean.
- **ESS, bulk and tail** → bulk ESS for point estimates, tail ESS for credible-interval edges; want hundreds per chain, not a handful.
- **Zero divergences (HMC/NUTS)** → divergences mean biased geometry; reparameterize (non-centered), raise `target_accept`, or shrink step size — do not ignore them.
- **BFMI / energy** → low BFMI flags poor momentum resampling; read the energy plot, not just the scalar.
- **Tree depth not saturating** → hitting `max_treedepth` is an efficiency-and-bias warning, not a pass.

## Anti-patterns
- Reporting posterior means with no R-hat or ESS at all.
- One long chain instead of several — no between-chain diagnostic exists.
- "A few divergences are fine" — they bias exactly the tails you report.
- Thinning to hide autocorrelation instead of reporting ESS honestly.
- Checking R-hat on the mean while reporting a 95% interval whose tail ESS was never looked at.

## Hard vs adaptable
- **Hard rule:** ≥4 chains, R-hat and ESS reported, divergences resolved or explicitly bounded, before any posterior number is trusted.
- **Adaptable:** exact thresholds (1.01 vs 1.05), chain count, and reparameterization tactics scale to the problem geometry.

## Related
- `predictive-checks` — convergence says the sampler worked; predictive checks say the model fits.
- `uncertainty-reporting-gate` — only a converged posterior earns a reported ± interval.
- `seed-and-stochasticity` — the non-MCMC cousin: ensemble over seeds for stochastic runs.
- `numerical-method-validation` — convergence of the forward solver, not the sampler.
