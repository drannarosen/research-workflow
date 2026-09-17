---
name: run-reproducibility
description: Run records, environment pins, artifacts so results rerun (scaled by stage). Use when a result must stay attributable, comparable, and rerunnable — logging a campaign of runs (fits, sweeps, production integrations, benchmarks), pinning the environment behind a citable number (locked deps, accelerator, float precision incl. JAX x64, seeds, input hashes), leaving an artifact bundle (command, resolved config, payload, manifest, plot-regeneration command), or recording an HPC job (scheduler script, node/GPU type, resources, exit status). Scales by stage: exploratory runs with the researcher need command, commit, and prediction vs result; the full record starts when a number is reported or compared across sessions. Don't use for the evidence close-out itself (→ verification-gate), input-dataset source and version (→ provenance), or why a configuration was chosen (→ decision-log-and-commits).
---

A number you can't trace to the code, configuration, environment, and job that produced it can't be
defended or rerun. How much you record depends on what the number is for.

## Stages
- **Exploratory, with the researcher in the loop** → the command, the commit (with a dirty-tree flag),
  and the approved prediction next to the result (→ `researcher-in-the-loop`). That is enough to tell
  a bug from a result and to rerun it this session.
- **Reported, or compared across sessions** → the full run record, environment, and campaign table
  below. Two numbers from different sessions aren't comparable until both have them. Capture the
  record when the run happens; an environment reconstructed afterward is not a record.
- **Released or published** → everything, plus the artifact bundle, frozen by
  `research-release-checklist`.

## 1. Run record
- **Identity** → run id, timestamp, git commit plus a dirty-tree flag. Results from uncommitted code
  are unattributable: commit first, or store the diff with the run.
- **Resolved config** → the full configuration as actually used (solver settings, parameters, seeds,
  input dataset id/version), serialized next to the outputs, not the flags you remember.
- **Metrics** → key outcomes (|ΔE/E|, χ²/dof, wall time) with their uncertainty, appended as a
  machine-readable row to a campaign table rather than left in terminal scrollback, and never
  overwriting the previous run in place. A "best result" is one logged row, not a winner tuned by
  uncommitted edits that can't be recovered.
- Seeds live once, in this record; everything else links to it.

## 2. Environment
- **Dependencies** locked (`uv.lock` or exact pins), interpreter version, and the backend versions that matter (`jax`, `jaxlib`).
- **Platform and accelerator** → OS/arch, CPU vs GPU/TPU, device model, CUDA/driver. The backend changes results.
- **Precision** → float32 vs float64 and what set it. Record `jax_enable_x64` even when a package sets it implicitly at import, so the default is visible rather than assumed. Silent float32 is a top cause of "irreproducible" drift.
- **Input hashes** → sha256 of every input or IC file; a path is not a pin.
- Capture it by machine (`uv pip freeze`, `jax.print_environment_info()`, an `env.json`), and say plainly what you can't pin (nondeterministic GPU reductions) instead of implying bit-exactness.

## 3. Artifact bundle (results that matter)
Exact command · resolved config · output payload · a small committed manifest (paths + key
diagnostics) · the plot-regeneration command · a completion note in the project's usual place. The
manifest links the run record and environment; it never restates seeds or lockfiles, so the copies
can't drift. Every cited claim resolves to a committed artifact path; a screenshot or plot without
the payload and regeneration command doesn't.

## 4. Cluster jobs
Scheduler and submit script, job id and array index, partition; node type, GPU/CPU model and count;
resources requested vs used; modules or container tag; exit status. An OOM-killed, time-limited, or
non-zero-exit job is a failed run, and its partial output is not a result. Don't assume a result
reproduces on a different node type without checking; keep outputs off scratch paths that vanish.

## Related
- `verification-gate` — the close-out that cites these records.
- `provenance` — source, version, and checksum of the input datasets the run record points to.
- `uncertainty-reporting-gate` — seed ensembles and the uncertainty logged metrics carry.
- `decision-log-and-commits` — why a configuration was chosen; this records what ran.
- `performance-measurement` — timing and scaling claims that also need the environment record.
- `researcher-in-the-loop` — the experiment proposal whose prediction an exploratory run is logged against.
- `research-release-checklist` — what a release freezes from these records.
