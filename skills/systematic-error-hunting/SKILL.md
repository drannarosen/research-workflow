---
name: systematic-error-hunting
description: Use before trusting a result's error bar — actively hunt the SYSTEMATIC biases that shift the central value without widening a statistical bar: selection effects, calibration/zero-point offsets, instrument or data artifacts, and code/model systematics not already in your uncertainty budget. The adversarial search for the bias you didn't list. Don't use for propagating the known budget into value ± σ (→ uncertainty-reporting-gate), the seed/sampling spread (→ seed-and-stochasticity), or general "is this result real" red-teaming (→ adversarial-result-check).
---

A tight error bar is not accuracy — it is precision around a possibly-wrong center. Statistical uncertainty shrinks with data; a systematic bias does not. It shifts the answer and hides inside a confident ±. Before trusting a result, hunt the systematics: enumerate the ways the central value could be wrong that no statistical bar would reveal, estimate or bound each, and surface the ones you cannot rule out. The dominant *systematic* often exceeds the entire statistical error bar.

## Hunting systematics
- **Selection / sampling bias** → what got into the sample, and what silently did not (Malmquist, survey completeness, censoring, survivorship)? A biased sample biases every downstream number.
- **Calibration / zero-point** → offsets, gains, unit/zero-point conventions, a miscalibrated reference — a constant shift no spread captures.
- **Instrument / data artifacts** → blending, saturation, deblending, masking, gaps treated as zeros, an outlier cut that quietly removes signal.
- **Code / method systematic** → a resolution-dependent result, a boundary effect, an estimator with finite-sample bias, an approximation used outside its regime (→ assumption-ledger).
- **Bound what you can't remove** → for each systematic you cannot eliminate, estimate its size and sign; an unquantified systematic is a stated caveat, never a silent omission.

## Anti-patterns
- Reporting `± σ_stat` as *the* uncertainty when an unaddressed systematic is larger than σ.
- Shrinking the error bar with more data while the dominant bias sits unexamined.
- "We assume no systematics" — the systematics you didn't look for are the ones that get you.
- Treating an outlier cut / mask / deblend as neutral preprocessing rather than a potential bias.

## Hard vs adaptable
- **Hard rule:** before a result's uncertainty is trusted, its systematic biases are actively hunted and either bounded or named as caveats. Precision without a systematics hunt is false confidence.
- **Adaptable:** depth of the hunt — scale to the claim's weight and how bias-dominated it could be. What must survive: *an explicit search for the bias not already in the budget.*

This is the *hunt for unmodeled bias*. Folding the resulting terms into a reported value ± σ (and statistical-vs-systematic bookkeeping) is `uncertainty-reporting-gate`; the stochastic/sampling spread is `seed-and-stochasticity`.

## Related
- `uncertainty-reporting-gate` — reports the budget of *known* sources; this hunts the systematics missing from that budget.
- `seed-and-stochasticity` — the statistical/sampling axis; this is the systematic-bias axis.
- `adversarial-result-check` — the general red-team; this is its systematics-focused specialization.
- `assumption-ledger` — many systematics are assumptions applied outside their regime.
