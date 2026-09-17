---
name: jax-performance
description: Speed up slow or memory-bound JAX — recompiles, transfers, donation, sharding. Use when JAX research code is slow or memory-bound — diagnose and fix recompilation (changing shapes or Python-level control flow), unnecessary host-device transfers, missing donate_argnums, and multi-device sharding (jit with shardings, shard_map), and time JAX correctly with block_until_ready. Don't use for JAX tracing/correctness bugs like leaked tracers or wrong vmap axes (→ jax-code-validator), or the general measure-first method and parallel scaling curves (→ performance-measurement).
---

JAX performance bugs live mostly at the compiler boundary: silent retracing, host-device round-trips,
and unbatched dispatch. The forward result is correct; it's just paying 10× for it. Find the
compile-boundary cost before reaching for hand-tuned kernels.

A JAX timing or speedup claim excludes compilation, blocks on async dispatch, and is checked against
the same output. Which fixes apply depends on the workload.

- **Kill recompilation**: `jit` retraces on new input shapes or Python-level branching. Watch for it
  (a `vmap` or loop whose shape changes every iteration retraces every iteration), keep shapes static,
  mark true constants `static_argnums`, and use `lax` control flow instead of Python loops over traced
  values.
- **Time honestly**: JAX dispatch is async; call `block_until_ready()` before stopping the clock, and
  exclude the first (compiling) call. The general measure-first method is `performance-measurement`.
- **Cut host-device transfers**: avoid `.item()`, prints, and NumPy conversions inside hot loops (for
  example, pulling a scalar to host every step just to log it); keep data on device. One sync per step
  destroys throughput.
- **Reuse buffers**: `donate_argnums` for update-in-place-friendly long integrations cuts allocation
  and peak memory.
- **Shard deliberately**: for multi-device, use `jax.jit` with explicit shardings (`jax.sharding.NamedSharding`) or `jax.shard_map` (`pjit` is the legacy spelling of sharded `jit`), and verify the
  partition does what you think, and that the function uses the extra devices at all, before chasing
  numbers.

## Related
- `jax-code-validator` — correctness of JAX tracing; this is its performance sibling.
- `performance-measurement` — the general measure-first method, and multi-device scaling once single-device is fast.
- `numerical-precision` — float32/64 choices that trade speed against accuracy.
