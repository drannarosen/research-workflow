---
name: performance-measurement
description: Profile before optimizing; measure speedups and strong/weak scaling correctly. Use before optimizing research code or claiming it is fast or scales — measure first on a representative workload, attribute the cost, fix the dominant term, and prove the speedup against a baseline with the science unchanged; for parallel code, measure strong and weak scaling with efficiency, name the breaking point (Karp–Flatt separates serial fraction from overhead), and hold work per worker fixed for O(N²) kernels. Don't use for JAX recompilation, host-device transfers, or sharding mechanics (→ jax-performance), generating the benchmark code itself (→ benchmark-generator), or recording a cluster job's provenance (→ run-reproducibility).
---

The bottleneck is rarely where intuition points, and "it scales" is a measurement. A performance
claim needs a baseline, a correctly timed measurement, and a check that the output didn't change.

**Scale the effort to the claim.** A quick "is this faster?" while developing needs only a warmed,
repeated timing and an output comparison. A speedup or scaling claim you will report, publish, or use
to request an allocation needs the full study below, and a scaling study above the project's cost
threshold is proposed to the researcher first (→ `researcher-in-the-loop`).

## Single node: measure, then optimize
- **Baseline first**: wall-clock and peak memory on a representative workload, before touching code.
- **Optimize the dominant term**: by Amdahl, a 10× speedup of a 5% routine saves ~4.5% overall.
  Attribute time to functions and lines with a profiler.
- **Time correctly**: exclude one-time compile/JIT/cache costs with a warm-up, repeat, and report
  median and spread. On GPU, block on async work before stopping the clock (`block_until_ready` or a
  host sync); otherwise you time the kernel launch, not the work.
- **One change, re-measure, compare outputs**: a speedup that changes the result is a bug.
- **Stop at fast enough**, and record what was tried.

## Parallel: strong and weak scaling
- **Strong scaling**: fixed problem, growing workers. Report speedup and efficiency (speedup ÷
  workers). Efficiency always falls; report where it crosses your threshold.
- **Weak scaling**: grow the problem with workers; ideal is flat time-to-solution. Hold work per
  worker fixed, not particle count: for O(N²) direct summation, doubling workers needs √2 × N, not
  2 × N, or you are measuring the algorithm's complexity rather than the parallel efficiency.
- **Name the wall**: communication, load imbalance, memory bandwidth, or serial fraction. The
  experimentally determined serial fraction (Karp–Flatt) `e = (1/S − 1/p) / (1 − 1/p)` separates
  them: constant `e` with growing p means a true serial fraction; `e` rising with p means overhead
  (communication, synchronization, imbalance). Don't attribute a slowdown to "overhead" without this
  separation.
- **Same answer at every worker count**: compare against the serial or reference result; more workers
  must not change the science.
- **State the regime**: "efficient to 16 GPUs, 60% at 64", not an unqualified "scales". Use three or
  more worker counts; two points are not a curve.

## Related
- `jax-performance` — JAX compile boundaries, transfers, donation, sharding.
- `benchmark-generator` — generates the timing and scaling-sweep code interpreted here.
- `run-reproducibility` — records the node/GPU configuration each scaling point ran on.
