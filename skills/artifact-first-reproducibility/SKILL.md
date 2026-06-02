---
name: artifact-first-reproducibility
description: Use when a research session produces meaningful results and you need durable manifests, payloads, plot scripts, and dated notes so later sessions can reason from artifacts instead of memory. Don't use for the in-the-moment command discipline (→ evidence-first-execution), the go/no-go close-out (→ verification-gate), or pinning the runtime environment itself (→ reproducible-environment-contract).
---

# Artifact-First Reproducibility

## Overview

If the result matters, leave artifacts behind — enough to rebuild it without you.

## Required artifact bundle

1. Exact command
2. Resolved config
3. Output payload or checkpoint data
4. Manifest with paths and key diagnostics
5. Plot regeneration command if plots are involved
6. Dated verification or audit note

## Rules

1. Prefer text artifacts over binary-only evidence.
2. Record enough metadata to rerun the exact case.
3. Tie every scientific claim to a committed artifact path.

## Anti-patterns

- screenshots without the underlying payload
- plots with no regeneration command
- close-out summaries that rely on conversational memory

## Related

- `evidence-first-execution` / `verification-gate` — the discipline that produces what gets archived here.
- `reproducible-environment-contract` — pins the *environment* (lockfile/interpreter/OS/seeds) these artifacts ran in.
- `decision-log-and-commits` — the dated note where decision rationale and commits live.
