---
name: adversarial-result-check
description: Use when you have a result you are about to report, cite, or build on — red-team it against the stable-but-wrong failure modes, starting with the cheapest. Lanes: an independent order-of-magnitude/units/sign envelope predicted before reading the output (the dropped 2π, cgs-vs-SI), numerical artifact, boundary/IC artifact, latent bug, a mundane alternative that fits the same data, and the systematic biases that shift the center without widening the error bar (selection, calibration, masking, estimator bias). Produces the strongest attacks plus the cheapest discriminating test for each. Don't use on a model still being developed (→ model-development; critique there is opt-in), for code review (→ scientific-code-reviewer), reporting the known uncertainty budget as value ± σ (→ uncertainty-reporting-gate), or judging a figure (→ figure-review).
---

The goal is to **kill the result**, not confirm it. A result you wanted, that didn't crash, and that "looks reasonable" is the dangerous case — convergence to a clean wrong answer is silent.

**Scope:** a number that will be *reported as a result, compared across sessions, or shipped*. Intermediate numbers in exploratory work get only lane 0 as a quick mental check; the full red-team applies the moment one becomes a claim.

## Lanes (cheapest first; stop when one kills it)

0. **Plausibility envelope** — *predict before you peek*: write the expected order of magnitude, units, and sign from a cruder independent path (dimensional estimate, virial/equilibrium argument, known scaling, closed-form limit) before reading the output, so the output can't anchor you. A 4π or factor-of-2 gap is a finding, not rounding. Outside the envelope, the bug is in the code *or* the estimate — find which before trusting either. This catches the slips that pass every type check: a dropped 2π, an off-by-factor normalization, cgs-vs-SI in code that carries bare floats.
1. **Numerical artifact** — could resolution, timestep, tolerance, a floor/clip, or round-off manufacture the signal? Kill: rerun at 2× resolution or tighter tolerance and check the effect moves the way the *physics* says, not the grid (a "shock" that sharpens forever under refinement is the grid).
2. **Boundary / initial-condition artifact** — does the signal live near a domain edge, in t≈0 transients, or in one RNG seed? Kill: move the boundary out, change the seed; a real effect survives.
3. **Latent bug** — a wrong unit, sign, index, or stale array landing in a believable range. Kill: lane 0's envelope plus a dimensional check of the formula.
4. **Mundane alternative** — what boring explanation fits the *same* data (a known scaling, a selection effect, a fit with too many free parameters)? The exciting hypothesis wins only on a prediction where they differ (→ discriminating-experiment-design).
5. **Systematic bias** — a tight error bar is precision around a possibly wrong center; systematics don't shrink with more data. Hunt what's *not* in the budget: selection and completeness (Malmquist, censoring, survivorship); calibration and zero-point offsets; masking, deblending, saturation, gaps treated as zeros, an outlier cut that removes signal; resolution-dependent or finite-sample-biased estimators; approximations used outside their regime (→ assumption-ledger). Bound each you can't remove by size and sign; an unquantified systematic is a stated caveat, never a silent omission.
6. **Hostile referee** — what does a competent adversary attack first? Usually the one number or figure the claim rests on. Pre-empt it.
7. **Gradient** (only if the result feeds gradient-based fitting or inference) — the forward value can be right while the gradient is wrong. Run the protocol in `gradient-validation`.

## Output

For each attack that survives: the failure it posits → the **single cheapest discriminating test** → `ran` / `not run`. A `ran` claim carries the command and its output; without them it is `not run`. Rank by `(plausibility × damage-if-true) / cost-to-test` and run the top one or two now. A reference-code or published-result comparison is rarely the cheapest discriminator; unless it is, list it as owed at the validation milestone rather than running it mid-development. Never report "survived" for a test you only described — an unrun discriminator is an open hole, not a pass.

## Anti-patterns
- "The run completed and the plot looks right" offered as evidence — that is the failure mode, not a defense.
- Reading the output first, then building an estimate that conveniently matches it.
- Reporting `± σ_stat` as *the* uncertainty while an unexamined systematic is larger.
- Listing attacks never executed and implying the result passed; attacking only the weak objections you can already beat.

## Related
- `uncertainty-reporting-gate` — reports the *known* budget as value ± σ; lane 5 hunts what's missing from it.
- `reference-parity-audit` — the rigorous, late-stage version of lane 0: match a trusted code at landmarks at the validation milestone.
- `discriminating-experiment-design` — design the discriminator before a result exists; this attacks one in hand.
- `gradient-validation` — the full protocol behind lane 7.
- `verification-gate` — the close-out format once the result survives.
