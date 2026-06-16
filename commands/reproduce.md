---
description: Capture a reproducibility contract for the current work — env lock, seeds, precision, inputs, commit.
argument-hint: [optional: the run/experiment to pin]
---
Use `reproducible-environment-contract` and `artifact-first-reproducibility` to make the current work reproducible: $ARGUMENTS

Do the actual capture — read real values from the environment, do not fabricate versions:
1. **Environment** — emit or refresh a lockfile using whatever the project uses (`uv`, `pip`, `conda`), and record the interpreter version, key library versions, and the float precision in effect (e.g. JAX x64 on/off).
2. **Determinism** — capture RNG seed(s) and note any device/parallelism nondeterminism (GPU nondeterminism, thread counts).
3. **Inputs** — list input dataset ids/versions and checksums (see `data-provenance`).
4. **Identity** — record the git commit, and flag explicitly if the working tree is dirty.

Write these into the project's reproducibility record (the lockfile + a run manifest), then show me exactly what was captured. If a piece can't be determined, say so rather than guessing.
