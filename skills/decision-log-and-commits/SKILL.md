---
name: decision-log-and-commits
description: Record physics/architecture decisions and write scoped research commits. Use either when capturing a nontrivial physics/architecture decision (record chosen / rejected / what-would-reverse-it while the reasoning is fresh) OR when landing changes so commits stay single-purpose and evidence-backed. Don't use for the close-out verification format (→ verification-gate) or archiving run artifacts and dated notes (→ run-reproducibility).
---

# Decision log and commits

A diff shows what changed, not why it beat the alternative or what would reverse it. Write the
decision down while the reasoning is fresh, then land it in single-purpose commits.

## Decision record

Record a decision that changes physics, equation/source ownership, a canonical lane, or a reported
result. A scientific choice in that list is the researcher's to approve (→ `researcher-in-the-loop`);
the record captures what they approved and why. Routine implementation choices belong in the commit
message.

1. Decision question · 2. Options considered · 3. Chosen option · 4. Rejected option · 5. Exact reason · 6. Code paths affected · 7. Evidence currently supporting it · 8. Evidence that would reverse it · 9. Provisional or locked.

Write it into the dated verification/audit note owned by `run-reproducibility`, not a separate
parallel doc, or inline in close-out prose if it is small and local. Separate measured evidence from
architectural judgment, name at least one rejected option, say when evidence is missing, and leave
the record as it was written rather than revising it later to make the choice look inevitable.

**Example:** "Q: fixed vs adaptive softening for collisionless runs? Proposed ε ≈ 0.05·d_mean (rejected ε=0: blows up at fixed dt); approved by the researcher 2026-03-02. Reason: prevents singularities without over-softening. Affects `softening.py`. Supported by: two-body energy test with |ΔE/E| scaling as Δt². Would reverse if: the mean 2K/|U| over seeds departs from 1 by more than 3σ of its seed-to-seed scatter at this N. Status: locked."

## Commits

Generic git, branch, and PR flow belongs to `superpowers:finishing-a-development-branch` (other
plugin) and any commit command the project defines. The research-specific rule: a change that moves
equation, source, or boundary ownership, or shifts a measured result, gets its own commit with the
supporting artifact path in the message (→ `run-reproducibility`). It does not ride inside a
"refactor", "cleanup", or "tidy" commit, because a reader bisecting a changed result looks for
scientific commits and skips those.

## Related

- `correct-cutover` — the owner change this records and commits as its own unit.
- `run-reproducibility` — owns the dated note/artifacts this log writes into and points at.
- `superpowers:finishing-a-development-branch` (other plugin) — generic merge/PR/branch flow this defers to.
- `verification-gate` — the evidence a decision (and its commit) must cite.
- `researcher-in-the-loop` — which decisions need the researcher's approval before they are recorded as made.
