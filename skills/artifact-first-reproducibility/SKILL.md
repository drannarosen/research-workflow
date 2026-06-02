---
name: artifact-first-reproducibility
description: Use when a research session produces meaningful results and you need durable manifests, payloads, plot scripts, and a completion note so later sessions can reason from artifacts instead of memory. Don't use for the in-the-moment command discipline (→ evidence-first-execution), the go/no-go close-out (→ verification-gate), or pinning the runtime environment itself (→ reproducible-environment-contract).
---

# Artifact-First Reproducibility

## Overview

If the result matters, leave artifacts behind — enough to rebuild it without you. Use the ecosystem's existing homes, not ad-hoc files:

- **`validation/validate_*.py`** — the standalone script that produced the result.
- **`validation/plots/*.png`** — the figures, regenerable from that script.
- **`.claude-work/TASK_X.Y_COMPLETE.md`** — the completion note (results, plot references, pass/fail).

## Required artifact bundle

1. Exact command
2. Resolved config
3. Output payload or checkpoint data
4. Manifest with paths and key diagnostics
5. Plot regeneration command if plots are involved
6. Completion note (`.claude-work/TASK_X.Y_COMPLETE.md`)

## Manifest schema (one example)

A small committed JSON beside the outputs — paths and diagnostics, plus a *link* to the pinned environment:

```json
{
  "command": "uv run validation/validate_plummer.py --N 1000 --seed 42",
  "config_hash": "sha256:9f2c…",
  "key_diagnostics": {"virial_Q": 0.501, "abs_dE_over_E": 7.3e-5},
  "outputs": {"plot": "validation/plots/plummer_virial.png",
              "payload": "validation/data/plummer_N1000.npz"},
  "env": "validation/env.json"
}
```

The manifest **references** the `env.json` / lockfile / seeds — it never restates them. Those are owned by `reproducible-environment-contract`; duplicating them here lets the two copies drift.

## Rules

1. Prefer text artifacts over binary-only evidence.
2. Record enough metadata to rerun the exact case.
3. Tie every cited scientific claim to a committed artifact path.

## Hard vs adaptable

- **Hard rule:** every cited claim resolves to a committed artifact path. A number with no artifact behind it is conversational memory, not a result.
- **Adaptable:** the exact bundle format — JSON manifest vs a table in the completion note, `.npz` vs HDF5. Match what the package already uses; the constraint is *resolvable + committed*, not the schema.

## Anti-patterns

- screenshots without the underlying payload
- plots with no regeneration command
- close-out summaries that rely on conversational memory
- a manifest that restates seeds/lockfile instead of linking the env contract

## Related

- `evidence-first-execution` / `verification-gate` — the discipline that produces what gets archived here.
- `reproducible-environment-contract` — owns the `env.json`/lockfile/seeds this manifest links to.
- `decision-log-and-commits` — where decision rationale and commits live.
