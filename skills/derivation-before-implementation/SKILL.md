---
name: derivation-before-implementation
description: Use when about to implement any non-trivial formula, algorithm step, or transformation — gate that the math is derived from a stated starting point (or cited to a specific equation) and dimensionally/limit-checked BEFORE it becomes code, so you implement a result you verified rather than one you guessed. Don't use for citing the source of a constant/coefficient (→ provenance-of-constants), proving a scheme converges at its order (→ numerical-method-validation), or the general stance of distrusting AI-produced work (→ researcher-in-the-loop).
---

You cannot debug your way to a correct formula you never derived. Any non-trivial expression — a Jacobian, a coordinate transform, a discretization, a likelihood, a change of variables — must be derived from a stated starting point (or cited to a specific equation, or declared as the researcher's own postulate) and checked before it is typed into code. Default: no non-trivial math is implemented from memory or by pattern-matching nearby code; the derivation exists first, in a comment, a notebook, or a resolvable reference.

A throwaway exploratory calculation (a scaling check in a notebook, a toy integration while developing a model) may start from a sketch. The gate applies before the formula is *relied on*: merged into solver code, or used to produce a reported number.

## Before you implement
- **State the starting point** → the governing equation or definition you derive from (B&T 2008 Eq. 4.x, the Hamiltonian, the DF moment) — not "the formula I remember." A researcher-original closure is a valid starting point: label it a *declared postulate* (recorded in `assumption-ledger`); it needs no citation, but everything derived *from* it still gets the dimensional and limit checks.
- **Derive or cite to the line** → show the steps (terse is fine) or cite a *specific* equation in a resolvable source. "Standard result" is not a derivation.
- **Dimensional check** → the derived expression has the right units and scaling before it becomes code (the symbolic companion to the plausibility envelope, lane 0 of `adversarial-result-check`).
- **Limit check** → it reduces correctly in a limit you can name (isotropic β=0, Newtonian, t→0, r→∞).
- **Then translate** → code it, and keep the derivation beside the implementation so the next reader checks code against math, not against faith.

## Anti-patterns
- Implementing a formula from memory or by analogy to similar code, then flipping signs/factors until a test passes — that is curve-fitting the bug.
- A dense expression with no derivation, no citation, and no limit check — unauditable even when correct.
- Copying a discretization or Jacobian from another codebase without re-deriving for *your* variables, units, and conventions.
- "The gradient looks right" — derive it (or grad-check it; → gradient-validation), don't eyeball it.

## Hard vs adaptable
- **Hard rule:** a non-trivial formula is derived, cited, or a labeled declared postulate, and limit-checked *before* it ships as code. Math implemented on a hunch is a defect waiting for a coincidence.
- **Adaptable:** how much derivation to show — full steps, key steps, or a precise citation — scaled to the formula's subtlety. What must survive is *a checkable line of reasoning*.

This skill governs getting the math right *before* code. Whether the resulting numerical scheme converges at its order is `numerical-method-validation`; whether autodiff gradients of it are correct is `gradient-validation`.

## Related
- `provenance-of-constants` — cite the *numbers*; this derives/cites the *formulas*.
- `numerical-method-validation` — once derived, prove the scheme converges at its order.
- `gradient-validation` — a derived gradient still needs a finite-difference check.
- `adversarial-result-check` — lane 0 is the numeric companion: the derived result must also land at the right order of magnitude.
- `researcher-in-the-loop` — AI-proposed derivations are exactly the high-risk case this guards; the assistant's own math gets no benefit of the doubt.
