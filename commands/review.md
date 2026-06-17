---
description: Multi-lens scientific code & figure review of a changeset, running the Review-cluster skills (correctness, numerics, JAX, robustness, craft, figures).
argument-hint: "[path | git ref | PR# ; default: current uncommitted diff]"
---
Run a deliberate, multi-lens review of: $ARGUMENTS

If no target was given, review the current uncommitted diff (`git diff` + `git diff --cached`, and untracked files); if the tree is clean, review the last commit (`git show`). State the scope you settled on before reviewing.

This is the deterministic entry point for the **Review** skill cluster — invoke it so the review actually happens rather than hoping a skill auto-surfaces. Apply each lens that the changeset touches; **skip (and say you skipped) lenses with nothing to review**:

- **`scientific-code-reviewer`** — physics/units correctness: dimensional consistency, conservation laws, physical bounds, CGS/solar conventions, AI-generated formulae.
- **`numerical-methods-auditor`** — stability & method correctness: catastrophic cancellation, overflow, convergence, symplectic/structure preservation.
- **`jax-code-validator`** — JIT compatibility, functional purity, PRNG-key handling, autodiff readiness, dtype/control-flow safety.
- **`error-handling-reviewer`** — exception specificity, boundary input validation, NaN/Inf detection, convergence-failure modes (cross-checks the `no-silent-except` hook).
- **`code-craft-reviewer`** — structure, abstraction/DRY, docstring/README freshness — research-code pragmatism, not enterprise patterns.
- **`plot-faithfulness-inspector`** — for any figure: read the rendered image and confirm what's plotted is what should be plotted (right array, honest axes, claimed effect real).
- **`benchmark-generator`** — only when a performance/scaling claim is being made and needs evidence.

For a large changeset, dispatch one sub-agent per applicable lens in parallel (each returns structured findings), then consolidate; for a small one, review inline.

Output a single **severity-tagged** report — `BLOCKER` / `MAJOR` / `MINOR` / `NIT` — each finding citing `file:line`, the lens that caught it, the concrete problem, and the fix. Lead with blockers. End with: lenses run, lenses skipped (and why), and one overall verdict (ship / fix-first / needs-author-input).

Adversarially verify before reporting: for each BLOCKER/MAJOR, state the evidence that distinguishes a real defect from a false positive (cross-link `adversarial-result-check`). Do not soften a real blocker to a nit; do not inflate a nit to a blocker. Review the code, don't run or change it unless I ask.
