---
name: numerical-precision
description: Use when writing or reviewing numerical code where floating-point representation can corrupt results — choosing float32 vs float64, guarding catastrophic cancellation, bounding overflow/underflow, and stopping NaN/Inf propagation, and being explicit about dtype across a pipeline (especially JAX, which defaults to float32). Gate that precision is a deliberate, justified choice and that the known FP hazards at that precision are handled. Don't use for whether a method converges at its theoretical order (→ numerical-method-validation), whether gradients are correct/finite (→ gradient-validation), or citing a constant's source (→ provenance-of-constants).
---

Float precision is a modeling choice, not a default to inherit. The representable-number grid silently shapes every result, and in JAX especially — float32 by default, float64 only if x64 is explicitly enabled — precision bugs masquerade as physics. Default: state the precision each computation needs and why, and handle the cancellation, overflow, and NaN hazards that bite at that precision.

## Checklist
- **Choose precision deliberately** → know whether the result needs float64 (long-time integrations, ill-conditioned solves, energy conservation to ~1e-10, summing many terms) or tolerates float32 (forward inference, GPU throughput). In JAX, float64 requires `jax.config.update("jax_enable_x64", True)` at startup — *verify* a value is actually 64-bit (`x.dtype`), don't assume it.
- **Guard catastrophic cancellation** → subtracting nearly-equal numbers (`a*a - b*b` near `a≈b`, `1 - cos x` for small `x`, the naive quadratic formula) destroys significant digits. Reformulate (`expm1`, `log1p`, `(a-b)*(a+b)`, stable quadratic, compensated/Kahan summation) instead of hoping float64 masks it.
- **Bound overflow / underflow** → exponentials, partition functions, products of many probabilities → work in log space, subtract a running max, use `logsumexp`.
- **Make NaN/Inf a failure, not a passenger** → a NaN that flows into a loss or metric and silently poisons it is worse than a crash. Assert finiteness at computation boundaries (and for gradients → gradient-validation), and find where the NaN is *born* rather than masking it downstream.
- **Keep dtype explicit across a pipeline** → an unintended float32↔float64 promotion/demotion (a stray Python float, a NumPy default, an integer literal) changes results. Pin and check dtypes at module interfaces.

## Anti-patterns
- Assuming float64 because the laptop NumPy uses it — then the JAX/GPU path silently runs the whole model in float32.
- "Adding float64 fixed it" with no diagnosis — the precision band-aid hides a formula that is still ill-conditioned and will fail again at scale.
- `clip` / `nan_to_num` to make NaNs disappear instead of locating where they originate.
- Reporting energy conservation or a convergence tolerance *below the precision floor* of the computation that produced it.

## Hard vs adaptable
- **Hard rule:** precision is a stated, justified choice, and NaN/Inf are caught at boundaries — never silently absorbed into a reported number.
- **Adaptable:** *which* precision, and *which* reformulation/stabilization. Match the conditioning of the problem; what must survive is **deliberate + hazard-aware**, not "float64 everywhere" cargo-culted onto code that's still numerically unstable.

This skill is about the floating-point *representation*. Whether the method converges at its claimed order is `numerical-method-validation`; whether gradients survive autodiff is `gradient-validation`.

## Related
- `numerical-method-validation` — order/convergence of the method; this is the FP substrate beneath it.
- `gradient-validation` — NaN/zero gradients, of which FP hazards (cancellation, saturation) are a common cause.
- `evidence-first-execution` / `verification-gate` — a precision claim (e.g. "|ΔE/E| < 1e-12") needs evidence produced at a precision that can actually support it.
