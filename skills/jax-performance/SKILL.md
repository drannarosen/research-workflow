---
name: jax-performance
description: Use when JAX research code is slow or memory-bound — diagnose and fix recompilation (changing shapes or Python-level control flow), unnecessary host-device transfers, missing donate_argnums, and multi-device sharding/pjit, and time JAX correctly with block_until_ready. Don't use for JAX tracing/correctness bugs like leaked tracers or wrong vmap axes (→ jax-code-validator), the general measure-first profiling method (→ profiling-discipline), or parallel scaling curves (→ scaling-validation).
---

JAX performance bugs live mostly at the compiler boundary: silent retracing, host-device round-trips, and unbatched dispatch. The forward result is correct — it's just paying 10× for it. Find the compile-boundary cost before reaching for low-level tricks.

## Discipline
- **Kill recompilation** → `jit` retraces on new input shapes or Python-level branching; watch for it, keep shapes static, mark true constants `static_argnums`, and use `lax` control flow instead of Python loops over traced values.
- **Time honestly** → JAX dispatch is async; call `block_until_ready()` before stopping the clock, and exclude the first (compiling) call from the measurement.
- **Cut host-device transfers** → avoid `.item()`, prints, and NumPy conversions inside hot loops; keep data on device. One sync per step destroys throughput.
- **Reuse buffers** → `donate_argnums` for update-in-place-friendly long integrations cuts allocation and peak memory.
- **Shard deliberately** → for multi-device, use `jit` with explicit sharding or `pjit`, and verify the partition does what you think before chasing numbers.

## Anti-patterns
- Timing a jitted function on its first call and reporting the compile time as runtime.
- A `vmap` or loop that retraces every iteration because a shape keeps changing.
- Pulling scalars to host (`.item()`) every step just to log them.
- Assuming more GPUs help before checking the function even uses them.
- Reaching for hand-tuned kernels before confirming retracing was the actual cost.

## Hard vs adaptable
- **Hard rule:** a JAX timing or speedup claim excludes compilation, blocks on async dispatch, and is checked against the same output.
- **Adaptable:** which fixes (static shapes, donation, sharding) apply depends on the workload.

## Related
- `jax-code-validator` — correctness of JAX tracing; this is its performance sibling.
- `profiling-discipline` — the general measure-first method behind any optimization.
- `scaling-validation` — multi-device scaling once single-device is fast.
- `numerical-precision` — float32/64 choices that trade speed against accuracy.
