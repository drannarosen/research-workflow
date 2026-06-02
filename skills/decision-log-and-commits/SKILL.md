---
name: decision-log-and-commits
description: Use when a research coding session involves nontrivial architectural/physics decisions and you need a durable record of what was chosen/rejected/what-would-reverse it, AND when finishing work so commits stay single-purpose and evidence-backed. Don't use for the close-out verification format (→ verification-gate) or archiving run artifacts (→ artifact-first-reproducibility).
---

# Decision Log and Commits

Research progress is lost when decisions live only in code diffs and when commits smear unrelated changes together. Write the decision down while the reasoning is fresh, then land it in clean, single-purpose commits.

## Decision record

For each nontrivial scientific/architectural decision, record:

1. Decision question · 2. Options considered · 3. Chosen option · 4. Rejected option · 5. Exact reason · 6. Code paths affected · 7. Evidence currently supporting it · 8. Evidence that would reverse it · 9. Provisional or locked.

Put it in a dated verification note, a dated plan/audit doc, or close-out prose if small and local. Rules: distinguish measured evidence from architectural judgment; record at least one rejected option; if evidence is missing, say so; don't rewrite history afterward to make the choice look inevitable.

## Commit discipline

Prefer separate commits for: (1) owner rewrite · (2) diagnostics/telemetry · (3) verification artifacts and notes · (4) instruction/prompt/doc updates. Rules: don't mix unrelated scientific and infrastructure changes; don't hide a hard cutover inside a "cleanup" commit; don't commit a scientific claim without the artifact path that supports it.

## Anti-patterns

- "we decided to do X" with no competing option named
- a "refactor" commit message hiding a scientific behavior change
- one giant commit with owner changes, docs, prompts, and plots
- conclusions recorded without stating what would falsify them

## Related

- `correct-cutover` — the owner change this records and commits as its own unit.
- `artifact-first-reproducibility` — the dated note/artifacts the decision log points at.
- `verification-gate` — the evidence a decision (and its commit) must cite.
