---
name: scaling-validation
description: Use when research code must run at scale or in parallel — validate strong and weak scaling, parallel efficiency, and the point where scaling breaks (communication, load imbalance, memory bandwidth, serial fraction), so a "scales to N nodes/GPUs" claim is measured rather than assumed. Don't use for single-node hotspot profiling (→ profiling-discipline), JAX compilation and sharding mechanics (→ jax-performance), or recording the cluster run's provenance (→ cluster-run-contract).
---

"It scales" is a measurement, not a hope. Parallel efficiency decays — the only question is where and why. Measure strong and weak scaling, find the wall, name the cause, and report the regime where the code is actually efficient.

## Discipline
- **Strong scaling** → fix the problem, grow the workers; track speedup and efficiency (speedup ÷ workers). Efficiency falls; report where it crosses your threshold.
- **Weak scaling** → grow problem and workers together; ideal is flat time-to-solution. Rising time exposes communication and synchronization cost.
- **Find the wall and name it** → communication overhead, load imbalance, memory bandwidth, or serial fraction (Amdahl). State the bottleneck, not just the curve.
- **Validate correctness across scales** → the parallel result must match the serial/reference result; more workers must not change the science.
- **Report the regime** → "efficient to 16 GPUs, 60% at 64" is the honest claim; an unqualified "scales" is not.

## Anti-patterns
- Claiming scaling from two data points.
- Reporting speedup without efficiency, hiding diminishing returns.
- Ignoring that the parallel result drifted from the serial one.
- Weak-scaling a problem that doesn't actually grow physically.
- Blaming "overhead" without separating communication from imbalance from memory.

## Hard vs adaptable
- **Hard rule:** a scaling claim is backed by a measured curve with efficiency and a named breaking point, and correctness is preserved across worker counts.
- **Adaptable:** the range of worker counts and which scaling mode (strong/weak) matters to the workload.

## Related
- `profiling-discipline` — find the single-node hotspot before scaling out.
- `benchmark-generator` — generates the scaling-sweep/timing code whose curves you interpret here.
- `jax-performance` — sharding/pjit and device transfers that govern scaling.
- `cluster-run-contract` — capture the node/GPU configuration each scaling point ran on.
- `reproducible-environment-contract` — pin the environment the scaling study used.
