---
name: jax-code-validator
description: Use when reviewing JAX code for tracing/JIT, PRNG, pytree, and vmap correctness — the traps that either raise at trace time or, worse, compile fine and silently compute the wrong thing (numpy RNG frozen into a constant, leaked tracers, a vmap over the wrong axis). Don't use for physics/units correctness or numerical stability (→ scientific-code-reviewer), gradient correctness (→ gradient-validation), or compile/transfer performance (→ jax-performance).
---

# JAX Code Validator

Most JAX mistakes are loud: a traced value used as a Python bool raises. Review effort belongs on the ones that are **silent** — they compile, run, and return a plausible wrong number. Behavior below was verified against JAX 0.11 (2026-09); re-check if a table entry surprises you.

## Silent traps (review these first)

| Trap | What happens | Fix |
|---|---|---|
| `np.random.*` (or any host-side numpy computation) inside a jitted function | Runs **once at trace time**; the value is baked in as a constant. Two calls return the identical "random" number. | `jax.random` with an explicit key argument. |
| PRNG key reuse | `normal(key)` twice gives identical draws — correlated "independent" samples. | `key, sub = jax.random.split(key)` before every use. |
| `vmap` over the wrong axis when sizes coincide | Square arrays (N×N, or N particles × N timesteps) broadcast without error along the wrong axis. | State `in_axes`/`out_axes` explicitly; test with non-square shapes. |
| Leaked tracer (stored on `self`, a global, or a closure cache during tracing) | `UnexpectedTracerError` later — or a stale traced value reused across calls. | Return state; never stash intermediates outside the function. |
| `print` inside jit | Prints the tracer once at trace time, never the runtime values. | `jax.debug.print`. |
| float32 default | Without `jax_enable_x64`, `jnp.array(1.0) + 1e-10 == 1.0` is `True` and CGS-scale products lose precision with no warning. | Enable x64 at program start; assert `x.dtype` in tests (→ `numerical-precision`). |

## Loud traps (easy to spot, easy to misdiagnose)

| Pattern | Actual behavior | Note |
|---|---|---|
| `if x > 0:` with traced `x` | Raises `TracerBoolConversionError` | Use `jnp.where` / `lax.cond`. |
| `if x.shape[0] > 10:` | **Works** — shapes are static | Retraces per distinct shape, not an error. |
| `x[:n]` with traced `n` | Raises `IndexError` | `static_argnums` for `n` (one compile per value), or a fixed-shape mask. |
| Plain `@dataclass` state passed through `jit` | Raises `TypeError` — not a pytree | `@jax.tree_util.register_dataclass` or `equinox.Module`. |
| `np.sum(tracer)` | Usually works via dispatch | Style issue, not a bug; `np.asarray(tracer)` / numpy functions that force a host array raise `TracerArrayConversionError`. |

## Review output

Findings as a short list, each with `file:line`, the trap, whether it is **silent** or **loud**, and the fix. Lead with silent traps. If a claim about JAX behavior is not in the tables above, run a three-line check before asserting it — JAX semantics change between versions.

## Related

- `gradient-validation` — finite-difference and autodiff gradient checks.
- `numerical-precision` — dtype and x64 policy for JAX research code.
- `jax-performance` — recompilation, host transfers, donation, sharding.
- `scientific-code-reviewer` — physics/units correctness outside JAX mechanics.
