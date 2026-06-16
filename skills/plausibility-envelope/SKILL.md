---
name: plausibility-envelope
description: Use when you obtain a computed number you're about to trust, report, or build on — gate it against an INDEPENDENT back-of-the-envelope estimate (expected order of magnitude, units, sign) before believing it. Catches the unit slip, the missing 2π, the factor-of-2 normalization, and the sign error that pass every type and unit check. Don't use for proving a method converges (→ numerical-method-validation), rigorous parity vs a reference implementation (→ reference-parity-audit), or reporting the uncertainty on an already-believed number (→ uncertainty-reporting-gate).
---

A number your code prints is a hypothesis, not a fact. Before any computed result is trusted, reported, or built upon, estimate independently what it *should* be — order of magnitude, units, sign, limiting scale — and confirm the computed value lands inside that envelope. The errors this catches (a dropped 2π, cgs-vs-SI, an off-by-factor normalization) sail through every unit and type check because the dimensions stay consistent; only an independent estimate exposes them.

## The envelope check
- **Predict before you peek** → write the expected order of magnitude, units, and sign from a simple argument *before* reading the code's output, so the output doesn't anchor you.
- **Use a cruder, independent path** → a dimensional estimate, a virial/equilibrium argument, a known scaling relation, a closed-form limit — anything that doesn't share the code's machinery.
- **Compare magnitudes, not digits** → does it agree to ~order unity and the right power of ten? A 4π or factor-of-2 gap is a finding, not a rounding aside.
- **Resolve disagreement before excitement** → outside the envelope, the bug is in the code *or* the estimate; find which before trusting either. A surprising result must clear this bar before it's allowed to be exciting.

## Anti-patterns
- Trusting a number because the code ran and the units type-check — unit-consistent-and-wrong is the entire failure mode.
- Reverse-rationalizing: reading the output first, then constructing an estimate that conveniently matches it.
- Waving off an order-of-magnitude mismatch as "just numerical" without locating the factor.
- Reporting a headline number with no sanity bound stated anywhere.

## Hard vs adaptable
- **Hard rule:** every result you trust/report/act on has passed an *independent* order-of-magnitude + units + sign check. No envelope, not trusted.
- **Adaptable:** how the estimate is made (dimensional analysis, scaling relation, limiting case) — match the quantity. What must survive is *independence from the code path* and *predict-before-peek*.

This is the fast, independent sanity bound. A rigorous match against a trusted reference implementation is `reference-parity-audit`; quantifying the uncertainty once you believe the value is `uncertainty-reporting-gate`.

## Related
- `adversarial-result-check` — the envelope is the first, cheapest adversarial test of a result.
- `reference-parity-audit` — the rigorous version: match a trusted code, not just an order of magnitude.
- `uncertainty-reporting-gate` — once the value is plausible, report its error honestly.
- `derivation-before-implementation` — the symbolic companion: right formula (derivation) and right size (envelope).
