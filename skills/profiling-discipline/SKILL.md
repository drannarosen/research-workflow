---
name: profiling-discipline
description: Use before optimizing any research code — measure first, find where time and memory actually go, optimize the dominant cost rather than a guess, and prove the speedup against a baseline. Covers profiling method, attributing the hotspot, and timing correctly. Don't use for parallel/cluster scaling behavior (→ scaling-validation), JAX-specific compilation and dispatch performance (→ jax-performance), or code readability and structure cleanups (→ code-craft-reviewer).
---

Optimization without measurement is superstition. The bottleneck is almost never where intuition points. Profile a representative workload, attribute the cost, fix the dominant term, and prove the speedup against a baseline — with correctness held fixed.

## Discipline
- **Measure before touching anything** → profile a representative workload; record a baseline wall-clock and peak memory.
- **Find the dominant cost** → optimize the top term. By Amdahl, speeding a 5% routine by 10× saves ~4% overall; attribute time to functions and lines, not vibes.
- **Time correctly** → warm up to exclude one-time compile/JIT/cache effects, repeat, and report median with spread; block on async work before stopping the clock.
- **Change one thing, re-measure** → confirm the speedup against the baseline on the same workload, and compare outputs so the optimization didn't change the science.
- **Stop at "fast enough"** → optimize to the requirement, not to exhaustion; record what was tried so the next person doesn't repeat it.

## Anti-patterns
- Rewriting a routine for speed without ever profiling it.
- Timing a single un-warmed run, where compilation or cache effects dominate.
- Optimizing a minor cost while the dominant term is untouched.
- Reporting a speedup with no baseline or no correctness check.
- Micro-optimizing Python loops that a single vectorized or compiled call would erase.

## Hard vs adaptable
- **Hard rule:** an optimization claim is backed by a before/after measurement on the same workload, with correctness verified.
- **Adaptable:** which profiler, workload size, and how far to optimize scale to the cost of the code.

## Related
- `scaling-validation` — how runtime behaves as resources or problem size grow.
- `jax-performance` — JIT recompilation, dispatch, and device-transfer costs in JAX.
- `benchmark-generator` — build the representative workloads you profile against.
- `code-craft-reviewer` — keep the optimized code readable.
