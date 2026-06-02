---
name: ownership-and-structure
description: Use when changing or reviewing solver/IC/mesh/boundary/source/diagnostics code in a research codebase — map who owns each quantity/equation/acceptance decision, define canonical vs legacy lanes, and stop tuning when the architecture itself is structurally wrong. Don't use to execute the break once a wrong owner is confirmed (→ correct-cutover) or for the close-out evidence format (→ verification-gate).
---

# Ownership and Structure

Most bad scientific edits come from unclear ownership. Before touching solver/boundary/source code, make ownership explicit; if the structure itself is wrong, stop tuning and say so. This skill covers three tightly-linked moves — **map ownership → detect structural mismatch → contract the lanes**. The actual API break is `correct-cutover`'s job.

## 1. Map ownership first

For the active lane, state:

1. Unknowns / DOFs
2. Enforced equations / constraints
3. Boundary-condition owners
4. Source-term owners (e.g. `eps_grav` in stellar work, the force kernel in N-body)
5. Which quantities are **rebuilt, solved, projected, or diagnostic-only**
6. Acceptance owner for stage transitions
7. Canonical path vs legacy path

Label every quantity or check in a status update as one of: solver-owned · rebuilt/externally-imposed · projected output · diagnostic self-consistency · independent validation.

## 2. Stop rule — when the architecture is wrong

If tuning isn't helping and any of these hold, **stop tuning** (further tuning only hides the problem):

- equations vs DOFs mismatch
- wrong boundary owner
- a source term rebuilt outside the enforced solve when it must be solver-owned
- canonical path depends on a legacy fallback
- diagnostics used as acceptance owners without independent justification

Then state: (1) the mismatch, (2) why tuning won't fix it, (3) the smallest ownership rewrite needed, (4) what code path must be retired/cut-over/quarantined. **Forbidden** stop-gaps: tolerance tuning, residual weighting, line-search tweaking, compatibility scaffolding, "let's see if it converges anyway."

## 3. Lane contract — canonical vs legacy

When canonical and legacy paths coexist, write the barrier down:

1. Canonical lane · 2. Legacy lane · 3. Acceptance owner for canonical · 4. Which code paths may feed canonical results · 5. Which legacy paths remain for control/debugging only · 6. Exact mechanism preventing legacy contamination.

Rules: canonical results must not silently route through legacy fallbacks; legacy paths are labeled non-canonical in code and reporting; delete a lane once its replacement is validated.

## Related

- `correct-cutover` — execute the owner change / API break once this map shows the owner is wrong.
- `minimal-falsifiable-slice` — scope the rewrite to the smallest provable change.
- `evidence-first-execution` / `verification-gate` — prove the new ownership actually holds.
