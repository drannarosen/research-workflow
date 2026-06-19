---
name: experiment-tracking
description: Use when running a campaign of computational experiments — fits, parameter sweeps, production integrations, benchmarks — and you need results to stay comparable and attributable over time. Gate that every significant run records its identity (code commit), full config, environment pointer, key metrics, and artifact location to a durable campaign-level log. Don't use for reproducing a single artifact end-to-end (→ artifact-first-reproducibility), pinning the environment itself (→ reproducible-environment-contract), or recording a design decision (→ decision-log-and-commits).
---

A research result you can't attribute to a specific run is an anecdote. Every significant run — a fit, a sweep, a production integration, a benchmark — must leave a durable record tying its outputs to the exact inputs and code that produced them, so that two numbers from two different days can actually be compared and the winner can be rerun. Default: no result is reported or acted on until it traces to a logged run.

## What every logged run records
A run is logged when its row answers "which inputs + code produced this number, and can I rerun exactly this one?":
- **Identity** → a run id + timestamp + the git commit that ran, including a dirty-tree flag. A result from uncommitted code is unattributable — commit first, or record the diff alongside the run.
- **Config** → the *full resolved* configuration, not just the flags you remember: hyperparameters, solver settings, RNG seed, and the input dataset id/version (→ data-provenance). Serialize it (YAML/JSON) next to the outputs, keyed by run id.
- **Environment pointer** → a reference to the env contract that was active (→ reproducible-environment-contract) — library versions, float precision, device — so a later regression is read as a regression, not mistaken for a science change.
- **Metrics** → the key scalar outcomes (final `|ΔE/E|`, χ²/dof, wall-time, loss) as a machine-readable row appended to a campaign-level table — never left in scrolled-away stdout. Carry their uncertainty (→ uncertainty-reporting-gate).
- **Artifacts pointer** → where the outputs/checkpoints/figures landed (→ artifact-first-reproducibility), keyed by the same run id.

## Anti-patterns
- Results that live only in terminal scrollback or a chat message — gone by next week, comparable to nothing.
- A metric reported without the config + commit that produced it ("it converged to 1e-6" — under which settings, which code?).
- Overwriting the previous run's outputs in place, so the campaign has a history of exactly one run.
- Tuning by editing code between runs without committing, so the *winning* configuration can no longer be recovered.
- A "best result" you cannot point to a single logged row for.

## Hard vs adaptable
- **Hard rule:** every result you report or act on traces to a recorded run = (commit + resolved config + metrics). No attribution, not a result — this is the no-fabrication rule applied to the experimental record.
- **Adaptable:** the mechanism — a CSV/JSONL the run script appends, an experiment tracker (MLflow / Weights & Biases), or a tidy `runs/<id>/` directory. Match the project's scale; what must survive is **comparability** (rows you can sort) and **recoverability** (rerun the winner).

This skill logs *what each run did and with what*; it does not re-execute a past run from scratch — that is `artifact-first-reproducibility`.

## Related
- `artifact-first-reproducibility` — this records the run; that captures and regenerates its artifacts.
- `reproducible-environment-contract` — the environment half of a run's identity.
- `cluster-run-contract` — the scheduler/hardware provenance for a run executed on an HPC cluster.
- `data-provenance` — the input-dataset id/version a run's config must point to.
- `decision-log-and-commits` — records *why* a configuration was chosen; this records *what* each run did and produced.
- `uncertainty-reporting-gate` — logged metrics should carry their uncertainty, not bare point values.
