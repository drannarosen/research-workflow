---
name: decision-log-and-commits
description: Use either when capturing a nontrivial physics/architecture decision (record chosen / rejected / what-would-reverse-it while the reasoning is fresh) OR when landing changes so commits stay single-purpose and evidence-backed. Don't use for the close-out verification format (→ verification-gate) or archiving run artifacts and dated notes (→ artifact-first-reproducibility).
---

# Decision Log and Commits

Research progress is lost when decisions live only in code diffs and when commits smear unrelated scientific changes together. Write the decision down while the reasoning is fresh, then land it in clean, single-purpose commits. These are **adaptable defaults** with one **hard rule** (below) — bias toward both, but the no-disguised-science-in-cleanup rule is non-negotiable.

## Decision record

For each nontrivial scientific/architectural decision, record:

1. Decision question · 2. Options considered · 3. Chosen option · 4. Rejected option · 5. Exact reason · 6. Code paths affected · 7. Evidence currently supporting it · 8. Evidence that would reverse it · 9. Provisional or locked.

Write it into the dated verification/audit note owned by `artifact-first-reproducibility` (not a separate parallel doc), or inline in close-out prose if small and local. Rules: distinguish measured evidence from architectural judgment; record at least one rejected option; if evidence is missing, say so; don't rewrite history afterward to make the choice look inevitable.

**Example:** "Q: fixed vs adaptive softening for collisionless runs? Chose ε ≈ 0.05·d_mean (rejected ε=0: blows up at fixed dt). Reason: prevents singularities without over-softening; matches CLAUDE.md integrator policy. Affects `softening.py`. Supported by: two-body energy test |ΔE/E|<1e-5. Would reverse if: virial Q drifts >5% off 0.5. Status: locked."

## Commit discipline

Generic git/branch/PR flow is **not** owned here — defer to `superpowers:finishing-a-development-branch` (other plugin) and the user's `/commit-smart` command. The one research-specific rule:

> **Never hide a scientific behavior change inside a "refactor", "cleanup", or "tidy" commit.** A change that moves equation/source/boundary ownership, or shifts a measured result, gets its own commit with the supporting artifact path in the message (→ `artifact-first-reproducibility`). This is the hard rule.

## Anti-patterns

- "we decided to do X" with no competing option named
- a "refactor" commit message hiding a scientific behavior change
- conclusions recorded without stating what would falsify them

## Rationalizations

| Excuse | Reality |
|---|---|
| "The diff shows what changed; no need to write the decision." | A diff shows *what*, never *why it beat the alternative* or *what would reverse it*. Record it. |
| "It's just a small refactor that also tweaks the kernel." | If it changes a scientific behavior, it is not a refactor. Separate commit, named honestly. |
| "I'll note the rationale later." | Later = lost. The reasoning is only fresh now. |

## Related

- `correct-cutover` — the owner change this records and commits as its own unit.
- `artifact-first-reproducibility` — owns the dated note/artifacts this log writes into and points at.
- `superpowers:finishing-a-development-branch` (other plugin) — generic merge/PR/branch flow this defers to.
- `verification-gate` — the evidence a decision (and its commit) must cite.
