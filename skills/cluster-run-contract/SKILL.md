---
name: cluster-run-contract
description: Use when research results come from HPC/cluster jobs (SLURM/PBS, multi-GPU, batch queues) — capture the job-to-artifact contract so a run is reproducible and attributable: scheduler script, node/GPU type, resource request, walltime, modules/container, seed, and output paths recorded with the result. Don't use for local environment pinning alone (→ reproducible-environment-contract), the per-run experiment log (→ experiment-tracking), or measuring scaling behavior (→ scaling-validation).
---

A figure that came off a cluster is only trustworthy if you can say which job produced it on what hardware. The scheduler script, the node type, and the resource request are part of the result's provenance — not disposable shell history.

## Contract
Record, alongside the run's outputs:

- **Job** → scheduler (SLURM/PBS), submit script, job ID, array index, partition/queue.
- **Hardware** → node type, GPU/CPU model and count, interconnect; results can depend on it through nondeterminism, precision, and OOM thresholds.
- **Resources** → cores/memory/walltime requested versus actually used; an OOM-killed or time-limited run is a *failed* run, not a result.
- **Software** → modules loaded, container image and tag, and the environment lock (→ reproducible-environment-contract).
- **Determinism** → the seed, and whether the result is bit-reproducible or only reproducible in distribution on this hardware (→ seed-and-stochasticity).
- **Outputs** → paths, checksums, and the commit that produced them (→ experiment-tracking).

## Anti-patterns
- A result whose only record of how it ran is lost terminal scrollback.
- Re-submitting with edited resources and not noting which job made the saved output.
- Ignoring a non-zero exit, OOM, or timeout and using the partial output anyway.
- Assuming a cluster result reproduces on a different node type without checking.
- Hardcoded scratch paths that vanish, breaking the artifact trail.

## Hard vs adaptable
- **Hard rule:** a saved cluster result records the job, the hardware, the resources, and the commit that produced it.
- **Adaptable:** how much of the contract is automated (job epilogue, manifest file) versus written by hand scales to how often you run.

## Related
- `reproducible-environment-contract` — the software-environment half of the contract.
- `experiment-tracking` — links each job to its commit, config, and outputs.
- `seed-and-stochasticity` — hardware-level nondeterminism on the cluster.
- `artifact-first-reproducibility` — every saved artifact traces to the job that made it.
