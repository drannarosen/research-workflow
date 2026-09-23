---
name: ownership-and-structure
description: Who owns each equation/BC/source term; stop when the architecture is wrong. Use when changing or reviewing solver/IC/mesh/boundary/source/diagnostics code in a research codebase — map who owns each quantity/equation/acceptance decision, define canonical vs legacy lanes, and stop tuning when the architecture itself is structurally wrong. The slash-list above is examples, not a checklist. Don't use to execute the break once a wrong owner is confirmed (→ correct-cutover) or for the close-out evidence format (→ verification-gate).
---

# Ownership and structure

Many bad scientific edits come from unclear ownership: a quantity nobody knows is rebuilt, a diagnostic
treated as validation, a canonical result quietly fed by a legacy path. Before touching solver,
boundary, or source code, make ownership explicit; if the structure itself is wrong, stop tuning and
say so. The three moves are map ownership, detect structural mismatch, and contract the lanes. The
API break itself is `correct-cutover`'s job, and changing equation, boundary, or source-term ownership
is a researcher checkpoint (→ `researcher-in-the-loop`).

## 1. Map ownership first

For the active lane, state:

1. Unknowns / DOFs
2. Enforced equations / constraints
3. Boundary-condition owners
4. Source-term owners (e.g. `eps_grav` in stellar work, the force kernel in N-body)
5. Which quantities are **rebuilt, solved, projected, or diagnostic-only**
6. Acceptance owner for stage transitions
7. Canonical path vs legacy path

### Ownership labels (canonical definition)

This is the canonical definition of these labels; other skills cite them rather than redefining them.
Label every quantity or check in a status update as exactly one of:

- **solver-owned**: the enforced solve sets it (a DOF or a directly enforced constraint).
- **rebuilt / externally-imposed**: reconstructed each step or set from outside the solve (e.g. an
  interpolated table, a fixed boundary value).
- **projected output**: derived from solved quantities, owns nothing (e.g. a luminosity computed
  post-solve).
- **diagnostic self-consistency**: an internal check (residual, conservation drift); tests the solve,
  and does not validate physics on its own.
- **independent validation**: comparison against a truth outside the solve. An analytic solution or
  limit is a development-stage check, run as early as the module can produce the quantity; a published
  reference or a separate code is the end-stage comparison.

The dangerous confusions are treating a diagnostic as independent validation (a tiny residual says the
solve is self-consistent, not that the physics is right) and letting a rebuilt quantity pass as
solver-owned. Diagnostics and analytic checks, with the supervisor's physics judgment, are a legitimate
basis for continuing development; comparison against a published reference or separate code is owed at
the milestone (→ `verification-gate`, *Validation stages*). The labels keep the two apart.

## 2. Stop rule: when the architecture is wrong

If tuning isn't helping and any of these hold, stop tuning, because further tuning only hides the
problem:

- equations vs DOFs mismatch
- wrong boundary owner
- a source term rebuilt outside the enforced solve when it must be solver-owned
- canonical path depends on a legacy fallback
- diagnostics used as acceptance owners without independent justification

Then state: (1) the mismatch, (2) why tuning won't fix it, (3) the smallest ownership rewrite needed,
(4) what code path must be retired, cut over, or quarantined.

Tolerance tuning, residual weighting, line-search tweaking, compatibility scaffolding, and "let's see
if it converges anyway" are not fixes for a structural mismatch, and none of them produces a canonical
or reported result. A tolerance or timestep probe is still legitimate as a diagnostic: propose it to
the researcher with what it would show (for example, whether an error falls at the scheme's order or
only ∝ Δt), run it once approved, and label its output as a probe. It informs the ownership diagnosis
and never becomes the fix.

**Worked example (computational astrophysics):** a stellar-evolution run violates global energy
conservation; shrinking the timestep helps, so the temptation is to keep shrinking. But
`eps_grav = −T ds/dt` is **rebuilt** from the previous converged model outside the Newton iteration
instead of being evaluated on the current iterate, a source term rebuilt outside the enforced solve
when it must be solver-owned. Stop. (1) Mismatch: the energy equation is solved against a lagged
source. (2) Why tuning won't fix it: with the source in the residual, each implicit step's energy
budget closes with its own `ds` to Newton tolerance at any Δt. The lagged source uses the previous
step's `ds/dt`, which differs by ≈ Δt · d(eps_grav)/dt, so the budget no longer closes. For backward
Euler that error is O(Δt), the same order as the scheme's truncation, so it shrinks with Δt but never
reaches solver tolerance; for a higher-order scheme it also caps the observed order at 1. Shrinking
Δt trades cost for a smaller structural error without removing it.
(3) Smallest rewrite: evaluate `eps_grav` inside the residual from the iterate's `s`, so the Jacobian
carries it. (4) Retire the post-step rebuild.

## 3. Lane contract: canonical vs legacy

When canonical and legacy paths coexist, write the barrier down:

1. Canonical lane · 2. Legacy lane · 3. Acceptance owner for canonical · 4. Which code paths may feed
canonical results · 5. Which legacy paths remain for control/debugging only · 6. Exact mechanism
preventing legacy contamination.

Canonical results do not route through legacy fallbacks, including "only when needed" fallbacks;
legacy paths are labeled non-canonical in code and reporting; a lane is deleted once its replacement
is validated.

## Related

- `correct-cutover` — execute the owner change / API break once this map shows the owner is wrong.
- `minimal-falsifiable-slice` — scope the rewrite to the smallest provable change.
- `verification-gate` — prove the new ownership actually holds.
- `researcher-in-the-loop` — ownership changes and canonical-lane replacement are checkpoints.
