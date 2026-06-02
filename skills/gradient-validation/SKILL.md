---
name: gradient-validation
description: Use when validating that the GRADIENTS of a differentiable model are correct (not just the forward value) — finite-difference grad-checks, NaN/Inf under jax.grad, and silent zero/blocked gradients from stop_gradient, argmax/argsort, where() with a singular dead branch, or clip/floor saturation. Don't use for forward-method convergence/conservation (→ numerical-method-validation) or reviewing JAX tracing mechanics in code (→ astro-code-review:jax-code-validator, other plugin).
---

A correct forward value does not imply a correct gradient. In differentiable astrophysics (gravax/progenax/stellax), every gradient-based fit, inference, or optimization rides on `jax.grad` being right — and it can be silently wrong while the loss looks perfect. **Before trusting any gradient-based result, grad-check it. This is the hard rule.**

## 1. Finite-difference grad-check (the anchor)
Compare the autodiff gradient against a central finite difference, component by component:

`g_fd ≈ [f(x + h·eᵢ) − f(x − h·eᵢ)] / (2h)`

- **Use float64** (`jax.config.update("jax_enable_x64", True)`); float32 noise swamps the check.
- **Pass criterion**: relative error `|g_ad − g_fd| / (|g_ad| + |g_fd| + ε)` below **~1e-5**.
- **Sweep the step** `h ∈ {1e-4 … 1e-7}` and take the best — too large = truncation error, too small = round-off. There is a sweet spot; one `h` can falsely fail.
- Check on a random direction for high-dim `x` (full Jacobian is expensive); test several seeds.

Runnable demo of the check + the fix below: see `example.py`.

## 2. NaN-gradient traps (forward finite, grad = nan / inf)
`sqrt`, `log`, `pow`, `1/x`, `norm` have infinite or undefined derivatives at their domain edge. The forward value can be clamped and finite while the backward pass propagates `nan` or `inf`.

**Real bug (King-model `K`-function):** `f(x) = sqrt(max(x, 0))`. Forward `f(0)=0` is fine, but `grad(f)(0.0)` is non-finite (`inf`/`nan`) — the derivative `0.5/sqrt(x)` blows up *and* autodiff still differentiates the dead `max` branch at the kink. (Run `example.py`: the buggy form gives a non-finite gradient at 0, the safe form gives `0.0`.)

**Canonical fix — the double-`where` / safe-primitive pattern**: clamp the input to a safe value, evaluate the primitive there, then `where` the *result*. Both branches must be finite so the cotangent is finite:

```python
safe_x = jnp.where(x > 0, x, 1.0)        # never feed 0 to sqrt
out = jnp.where(x > 0, jnp.sqrt(safe_x), 0.0)   # select after
```

A single `where(x>0, sqrt(x), 0.0)` is NOT enough — `sqrt(x)` is still evaluated (and differentiated) at `x=0`, so the `nan` survives. Clamp *before* the primitive.

## 3. Zero / blocked-gradient traps (grad = 0 silently)
A wrong-but-finite gradient is worse than a crash. Watch for:
- **`argmax` / `argsort` / `round` / `floor`** — piecewise-constant, gradient is zero almost everywhere. Use a softmax/soft-rank surrogate if you need to differentiate the selection.
- **Hard thresholds / step functions** — zero gradient in the flat region; the optimizer gets no signal.
- **`clip` / floor saturation** — once pinned at the bound, `∂out/∂x = 0`. A "floor as a fix" silently kills the gradient there.
- **`jax.lax.stop_gradient`** — verify every use is *intended*; an accidental one blocks learning on that path.

## Checklist
- [ ] float64 on; FD vs `jax.grad` rel-err < 1e-5, with an `h`-sweep.
- [ ] gradient finite (no `nan`/`inf`) at domain edges and special points (0, boundaries, equal masses, r=0).
- [ ] every `sqrt`/`log`/`pow`/`norm` near its edge uses the double-`where` safe pattern.
- [ ] no unintended `stop_gradient`, `argmax`/`argsort`, hard threshold, or saturated `clip`/floor on the differentiated path.
- [ ] checked at ≥2 seeds / points, not one lucky spot.

**Adaptable**: which `h`, how many directions/seeds, the surrogate for a needed hard op. **Not adaptable**: grad-checking before trusting gradient-based inference at all.

## Related
- `numerical-method-validation` — the forward-method analogue (order/conservation); pair them for a differentiable solver.
- `adversarial-result-check` — its gradient/autodiff attack lane invokes this protocol.
- `astro-code-review:jax-code-validator` (other plugin) — reviews JAX tracing/PRNG/JIT mechanics in source; this skill validates the gradient's numerical correctness.
