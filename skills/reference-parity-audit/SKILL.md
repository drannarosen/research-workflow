---
name: reference-parity-audit
description: Use when a change claims parity with a reference implementation or published numerical result (MESA, REBOUND, a published code/dataset) and you need a file-backed audit of how the reference actually works plus checkpoint-matched comparison at physical landmarks — not vague "looks like" trajectory similarity. Don't use for general close-out verification (→ verification-gate), or for validating a method against its own theory including comparison to an analytic/manufactured solution (→ numerical-method-validation).
---

# Reference Parity Audit

"Reference-like" is not a claim. Parity has two halves: **audit how the reference is actually implemented** (read its source), and **compare at matched physical landmarks** (not arbitrary pseudo-time positions). If a domain lens exists under `lenses/`, load it for the concrete checklist; otherwise instantiate the generic questions below.

**Hard:** stating the per-observable tolerance and the pinned reference version before comparing. **Adaptable:** which landmarks and observables you compare at.

## 1. Audit the reference (how it really works)

Read the reference's own source/docs and answer, for the regime you claim parity in:

1. How does it construct the starting state / initial conditions?
2. How does it relax or evolve before results are meaningful?
3. Where do the key source terms / forces enter the bookkeeping?
4. What adaptive machinery (remesh, timestep control, regularization) is active?
5. What stop criteria define the landmark you are comparing at?
6. What boundary / surface / closure choice is active?

## 2. Compare at matched landmarks

Pick the reference's physical landmarks **first**, then compare your code at the corresponding states — never at arbitrary pseudo-time. Report the regime's defining observables at each landmark (the lens lists them; generically: the conserved/characteristic quantities and the relevant profiles). Don't call a trajectory "parity" if the landmarks aren't matched.

**State the per-observable agreement tolerance before you look at the diff.** Anchor it to the *reference's documented precision* (its quoted convergence tolerance, its own published error bars, its solver settings) — not to whatever difference you happen to observe. A tolerance read off the observed gap is circular: it can only pass. Pin the reference **version** — release tag / commit / build flags / option set — and record it (→ `reproducible-environment-contract`); MESA, REBOUND, etc. change defaults and physics between versions, so "parity" against an unspecified build is unfalsifiable.

## 3. Label honestly

Use exactly one: **file-backed parity** · **partial parity** · **analogy only** · **not yet proven**. Required outputs: exact reference files inspected · exact local files compared · what matches · what departs · what evidence is still missing before claiming parity. If the landmark definition is unclear, the answer is "not yet proven."

## Lenses

- `lenses/mesa.md` — stellar evolution vs MESA (seed/relax/`eps_grav`/remesh/surface closure; `R_surf`/`L_surf`/`T_eff`/`T_c`/`rho_c` landmarks).
- `lenses/nbody.md` — N-body vs REBOUND (**highest-value gap; stub only — flesh out on first real parity run**): integrator/IC/softening/units questions; `E`/`L`/`a`/`e` and orbit-phase landmarks.
- (add `lenses/rad-transfer.md` as a one-file addition when that domain needs it.)

## Related

- `numerical-method-validation` — when there's no reference code but a theoretical convergence rate / conservation law to check against.
- `reproducible-environment-contract` — pins the reference's version/build flags so a parity claim stays falsifiable.
- `verification-gate` — gates the parity claim this audit produces.
