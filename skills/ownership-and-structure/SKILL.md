---
name: ownership-and-structure
description: Use when changing or reviewing solver/IC/mesh/boundary/source/diagnostics code in a research codebase — map who owns each quantity/equation/acceptance decision, define canonical vs legacy lanes, and stop tuning when the architecture itself is structurally wrong. The slash-list above is examples, not a checklist. Don't use to execute the break once a wrong owner is confirmed (→ correct-cutover) or for the close-out evidence format (→ verification-gate).
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

### Ownership-label taxonomy (canonical definition)

**This is the canonical definition of these labels; other skills cite them — do not redefine them elsewhere.** Label every quantity or check in a status update as exactly one of:

- **solver-owned** — the enforced solve sets it (a DOF or a directly enforced constraint).
- **rebuilt / externally-imposed** — reconstructed each step or set from outside the solve (e.g. an interpolated table, a fixed boundary value).
- **projected output** — derived *from* solved quantities, owns nothing (e.g. a luminosity computed post-solve).
- **diagnostic self-consistency** — an internal check (residual, conservation drift); tests the solve, never validates physics on its own.
- **independent validation** — comparison against an external truth (analytic solution, published reference, separate code).

The dangerous confusions: treating a **diagnostic** as **independent validation**, or letting a **rebuilt** quantity masquerade as **solver-owned**.

## 2. Stop rule — when the architecture is wrong (HARD gate)

This is a **hard gate**, not an adaptable default. If tuning isn't helping and any of these hold, **stop tuning** (further tuning only hides the problem):

- equations vs DOFs mismatch
- wrong boundary owner
- a source term rebuilt outside the enforced solve when it must be solver-owned
- canonical path depends on a legacy fallback
- diagnostics used as acceptance owners without independent justification

Then state: (1) the mismatch, (2) why tuning won't fix it, (3) the smallest ownership rewrite needed, (4) what code path must be retired/cut-over/quarantined. **Forbidden** stop-gaps: tolerance tuning, residual weighting, line-search tweaking, compatibility scaffolding, "let's see if it converges anyway."

**Worked example (computational astrophysics):** an N-body run won't conserve energy; shrinking the timestep helps a little, so the temptation is to keep shrinking. But the potential energy is computed *without* the `G` factor while forces include it — an **equations-vs-DOFs / source-owner mismatch**, not a step-size problem. Stop. (1) Mismatch: PE owner drops `G`. (2) Tuning dt only masks the constant offset. (3) Smallest rewrite: make the energy diagnostic use the same `G`-bearing kernel as the force. (4) Retire the standalone PE expression. No tolerance tuning will fix a wrong owner.

## 3. Lane contract — canonical vs legacy

When canonical and legacy paths coexist, write the barrier down:

1. Canonical lane · 2. Legacy lane · 3. Acceptance owner for canonical · 4. Which code paths may feed canonical results · 5. Which legacy paths remain for control/debugging only · 6. Exact mechanism preventing legacy contamination.

Rules: canonical results must not silently route through legacy fallbacks; legacy paths are labeled non-canonical in code and reporting; delete a lane once its replacement is validated.

## Rationalizations

| Excuse | Reality |
|---|---|
| "One more tolerance/dt tweak and it'll converge." | If a stop-rule condition holds, tuning hides the structural bug. Stop and name the owner. |
| "The residual is tiny, so the physics must be right." | A small diagnostic is self-consistency, not independent validation. Different labels. |
| "A thin wrapper keeps the legacy path working for now." | Compatibility scaffolding is a forbidden stop-gap; it lets the wrong owner survive. |
| "Canonical falls back to legacy only when needed." | A canonical lane that silently routes through legacy is contaminated. Write the barrier. |

## Red flags

- Reaching for tolerance/residual-weight/line-search tweaks when results won't converge.
- Citing a diagnostic (drift, residual) as proof the physics is correct.
- A source term rebuilt outside the enforced solve but treated as solver-owned.
- Canonical results that can route through a legacy fallback with no stated barrier.

## Related

- `correct-cutover` — execute the owner change / API break once this map shows the owner is wrong.
- `minimal-falsifiable-slice` — scope the rewrite to the smallest provable change.
- `evidence-first-execution` / `verification-gate` — prove the new ownership actually holds.
