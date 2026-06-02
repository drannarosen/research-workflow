---
name: uncertainty-reporting-gate
description: Use when a result is about to be reported as a number — derived quantities, model-comparison statistics, inferred parameters, energy/momentum budgets — to require an uncertainty budget (dominant sources named, estimation method stated, value ± uncertainty or credible interval) before the value ships. A bare point value is not a finished result. Don't use for the binary pass/fail close-out (→ verification-gate) or for validating a method's convergence/conservation (→ numerical-method-validation).
---

Gate that blocks any result from shipping as a bare point value. Default behavior: refuse to report `x = 3.41` and instead force `x = 3.41 ± 0.07` (or a credible interval), with the dominant uncertainty source named and its estimation method stated.

## Uncertainty budget (required before reporting)
Enumerate the contributing sources, estimate each, and identify which dominates:
- **Statistical / sampling** — finite samples, stochastic ICs, Monte Carlo draws. Estimate by ensemble spread, bootstrap, or posterior width.
- **Numerical / discretization** — timestep, grid/mesh resolution, tolerance, truncation. Estimate by convergence study (→ numerical-method-validation) and forward propagation.
- **Model / parameter** — input constants, assumed physics, prior choices. Estimate by varying within plausible ranges or marginalizing (Bayesian posterior).

State which source dominates and by roughly how much. If you cannot estimate a source, say so explicitly — an unquantified source is a stated caveat, not a silent omission.

## Reporting rules
- Report `value ± 1σ` (or a stated credible interval, e.g. 16th/84th percentile) — never a bare point value.
- Match significant figures to the uncertainty; do not over-report digits the error bar cannot support.
- Name the dominant source inline (e.g. "dominated by timestep discretization, not sampling").
- Distinguish statistical from systematic; do not fold a known systematic into a statistical bar without saying so.
- For derived/propagated quantities, state the propagation method (linearized, Monte Carlo sampling of inputs, full posterior).

## Anti-patterns
- A point estimate with no error bar presented as a finished result.
- A symmetric `±` slapped on a manifestly skewed or bounded quantity (use an interval).
- Quoting machine precision on a quantity whose dominant uncertainty is at the percent level.
- Claiming a difference between two results without checking it against their combined uncertainty.

## Related
- `verification-gate` — the close-out a quantified result plugs into.
- `numerical-method-validation` — discretization uncertainty comes from here.
- `adversarial-result-check` — pressure-test the result before quantifying it.