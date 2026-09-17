---
name: numerical-precision
description: Use when writing or reviewing numerical code where floating-point representation can corrupt results — choosing float32 vs float64, guarding catastrophic cancellation, bounding overflow/underflow, and stopping NaN/Inf propagation, and being explicit about dtype across a pipeline (especially JAX, which defaults to float32). Gate that precision is a deliberate, justified choice and that the known FP hazards at that precision are handled. Don't use for whether a method converges at its theoretical order (→ numerical-method-validation), whether gradients are correct/finite (→ gradient-validation), or citing a constant's source (→ provenance).
---

Float precision is a modeling choice, not a default to inherit. The representable-number grid shapes
every result, and in JAX (float32 by default, float64 only if x64 is explicitly enabled) precision
bugs can look like physics. State the precision each computation needs and why, and handle the
cancellation, overflow, and NaN hazards that bite at that precision. Which precision and which
stabilization depend on the conditioning of the problem; float64 everywhere does not fix a formula
that is still ill-conditioned.

This skill covers the floating-point representation. Whether the method converges at its claimed order
is `numerical-method-validation`; whether gradients survive autodiff is `gradient-validation`.

## Checklist
- **A reported error below ~1e-7 in JAX needs x64 evidence**: float32 resolution is ~1.2e-7, so a
  claimed `|ΔE/E| = 3e-12` from float32 JAX is an artifact. More generally, a conservation or
  convergence figure below the precision floor of the computation that produced it is not a result.
  The `inference_precision_gate.sh` Stop hook blocks such a claim unless `jax_enable_x64` appears in
  the message, the turn, or the repo.
- **Choose precision deliberately**: know whether the result needs float64 (long-time integrations,
  ill-conditioned solves, energy conservation to ~1e-10, summing many terms) or tolerates float32
  (forward inference, GPU throughput). In JAX, float64 requires
  `jax.config.update("jax_enable_x64", True)` at startup. Check that a value is actually 64-bit
  (`x.dtype`); NumPy defaulting to float64 on a laptop says nothing about the JAX/GPU path.
- **Guard catastrophic cancellation**: subtracting nearly equal numbers (`a*a - b*b` near `a≈b`,
  `1 - cos x` for small `x`, the naive quadratic formula) destroys significant digits. Reformulate
  (`expm1`, `log1p`, `(a-b)*(a+b)`, stable quadratic, compensated/Kahan summation) rather than relying
  on float64 to mask it. If switching to float64 made a problem go away, find the ill-conditioned
  expression anyway; it will fail again at scale.
- **Bound overflow and underflow**: exponentials, partition functions, and products of many
  probabilities belong in log space; subtract a running max, use `logsumexp`.
- **Make NaN/Inf a failure, not a passenger**: a NaN that flows into a loss or metric and silently
  poisons it is worse than a crash. Assert finiteness at computation boundaries (for gradients →
  `gradient-validation`) and find where the NaN is born. `clip` or `nan_to_num` that makes NaNs
  disappear hides the origin.
- **Keep dtype explicit across a pipeline**: an unintended float32↔float64 promotion or demotion (a
  stray Python float, a NumPy default, an integer literal) changes results. Pin and check dtypes at
  module interfaces.

## Related
- `numerical-method-validation` — order/convergence of the method; this is the FP substrate beneath it.
- `gradient-validation` — NaN/zero gradients, of which FP hazards (cancellation, saturation) are a common cause.
- `verification-gate` — a precision claim (e.g. "|ΔE/E| < 1e-12") needs evidence produced at a precision that can actually support it.
