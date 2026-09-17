---
name: uncertainty-reporting-gate
description: Report numbers as value ± uncertainty with dominant source; seed ensembles. Use when a result is about to be reported as a number — derived quantities, fitted or inferred parameters, energy/momentum budgets, anything from stochastic runs (random seeds, stochastic ICs, Monte Carlo, bootstrap) — to report value ± uncertainty with the dominant source named, judge stochastic results across a seed ensemble rather than one lucky draw, and choose σ vs σ/√N vs σ/√N_eff correctly. Don't use for the pass/fail close-out (→ verification-gate), a method's convergence or conservation (→ numerical-method-validation), sampler diagnostics (→ bayesian-inference-gate), or hunting unmodeled systematics (→ adversarial-result-check).
---

A reported number carries its uncertainty and says where the uncertainty comes from. `x = 3.41 ± 0.07, dominated by timestep discretization` is a result; `x = 3.412` is not.

This applies to a number that will be reported as a result, compared across sessions, or shipped. Exploratory and intermediate numbers are labeled *exploratory* and reported against their prediction (→ `verification-gate`); the budget applies once one becomes a claim.

## Budget
Name the contributing sources, estimate each, and say which dominates and by roughly how much:
- **Statistical / sampling** — finite samples, stochastic ICs, Monte Carlo: ensemble spread, bootstrap, or posterior width.
- **Numerical / discretization** — timestep, resolution, tolerance: a convergence study (→ numerical-method-validation).
- **Model / parameter** — input constants, assumed physics, priors: vary within plausible ranges or marginalize. The ranges are scientific choices for the researcher to approve (→ `assumption-ledger`).

A source you cannot estimate is stated as a caveat. Keep statistical and systematic separate unless you say you combined them.

## Stochastic results (seeds, ensembles)
- **One seed is one draw, not the answer.** Judge a reported stochastic result across an ensemble of seeds; a single-seed exploratory run is fine if labeled. Is the effect larger than the seed-to-seed scatter? A difference inside the spread is not a result.
- **Decide what the claim is about.** The *ensemble mean* gets σ/√N. What a *single realization* does (one cluster, one chaotic trajectory) gets σ itself — for N-body relaxation, turbulence, or stochastic ICs, the realization spread is usually the physical prediction, not noise to average away.
- **Correlated samples** (MCMC chains, time series) use σ/√N_eff with N_eff = N/(1+2∑ρ_k); raw N understates the error by √(N/N_eff).
- **Keep every seed**, including the ones that didn't "work" (→ null-result-integrity).
- **Count the trials.** When several seeds, cuts, or parameter points were tried, the significance of the best one must account for all of them (a look-elsewhere or multiple-comparison correction); report how many were tried.
- **Hidden nondeterminism** — GPU kernels, parallel reductions, async scheduling — moves results even with a fixed seed. Know which results are bit-reproducible and which only reproduce in distribution. Seeds are recorded once in the run record (→ run-reproducibility).

## Reporting
- `value ± 1σ`, or an interval (16th/84th percentile) for skewed or bounded quantities.
- Significant figures follow the uncertainty: `3.412 ± 0.068` → `3.41 ± 0.07`, not machine-precision digits on a percent-level quantity.
- Name the dominant source inline and the propagation method for derived quantities (linearized, Monte Carlo over inputs, full posterior).

## Related
- `verification-gate` — the close-out a quantified result plugs into.
- `adversarial-result-check` — hunts the systematics missing from this budget (lane 5).
- `bayesian-inference-gate` — only a converged posterior earns a reported interval.
- `numerical-method-validation` — where discretization uncertainty comes from.
- `null-result-integrity` — the seeds and runs that didn't work stay on record.
