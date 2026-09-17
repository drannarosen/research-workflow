---
name: performance-measurement
description: Use before optimizing research code or claiming it is fast or scales — measure first on a representative workload, attribute the cost, fix the dominant term, and prove the speedup against a baseline with the science unchanged; for parallel code, measure strong and weak scaling with efficiency, name the breaking point (Karp–Flatt separates serial fraction from overhead), and hold work per worker fixed for O(N²) kernels. Don't use for JAX recompilation, host-device transfers, or sharding mechanics (→ jax-performance), generating the benchmark code itself (→ benchmark-generator), or recording a cluster job's provenance (→ run-reproducibility).
---

The bottleneck is almost never where intuition points, and "it scales" is a measurement, not a hope. Every performance claim needs a baseline, a correctly timed measurement, and proof the output didn't change.

**Scope:** a speedup or scaling claim you will *report, publish, or use to request allocation*. A quick "is this faster?" while developing needs only a warmed, repeated timing — not a full study.

## Single-node: measure, then optimize
- **Baseline first** → wall-clock and peak memory on a representative workload, before touching code.
- **Optimize the dominant term** → by Amdahl, a 10× speedup of a 5% routine saves ~4.5% overall. Attribute time to functions and lines with a profiler, not by guess.
- **Time correctly** → exclude one-time compile/JIT/cache costs with a warm-up, repeat, report median and spread. On GPU, block on async work before stopping the clock (`block_until_ready` or a host sync) — otherwise you time the kernel launch, not the work.
- **One change, re-measure, compare outputs** → a speedup that changes the result is a bug.
- **Stop at fast enough** → and record what was tried.

## Parallel: strong and weak scaling
- **Strong scaling** → fixed problem, growing workers: report speedup *and* efficiency (speedup ÷ workers). Efficiency always falls; report where it crosses your threshold.
- **Weak scaling** → grow problem with workers; ideal is flat time-to-solution. Hold **work per worker** fixed, not particle count: for O(N²) direct summation, doubling workers needs √2 × N, not 2 × N, or you are measuring the algorithm's complexity, not the parallel efficiency.
- **Name the wall** → communication, load imbalance, memory bandwidth, or serial fraction. The experimentally determined serial fraction (Karp–Flatt) `e = (1/S − 1/p) / (1 − 1/p)` separates them: constant `e` with growing p means a true serial fraction; `e` rising with p means overhead (communication, synchronization, imbalance).
- **Same answer at every worker count** → compare against the serial or reference result; more workers must not change the science.
- **State the regime** → "efficient to 16 GPUs, 60% at 64" — never an unqualified "scales". Three or more worker counts; two points are not a curve.

## Anti-patterns
- Optimizing without a profile; timing one un-warmed run.
- A speedup with no baseline, or no check that the output is unchanged.
- Speedup reported without efficiency; weak scaling a problem whose work per worker grows.
- Blaming "overhead" without separating communication from imbalance from serial fraction.

## Related
- `jax-performance` — JAX compile boundaries, transfers, donation, sharding.
- `benchmark-generator` — generates the timing and scaling-sweep code interpreted here.
- `run-reproducibility` — records the node/GPU configuration each scaling point ran on.
