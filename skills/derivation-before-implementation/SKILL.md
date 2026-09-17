---
name: derivation-before-implementation
description: Derive a non-trivial formula or an experiment's prediction before code or runs. Use when about to implement any non-trivial formula, algorithm step, or transformation, or to state the prediction an experiment will be judged against — gate that the math is derived from a stated starting point (or cited to a specific equation, or a postulate the researcher has declared) and dimensionally/limit-checked BEFORE it becomes code, so you implement a result you verified rather than one you guessed. Don't use for citing the source of a constant/coefficient (→ provenance), proving a scheme converges at its order (→ numerical-method-validation), or the session stance on which choices need the researcher's approval (→ researcher-in-the-loop).
---

A formula that was never derived can't be debugged into correctness; sign and factor flips until a
test passes fit the bug rather than fix it. A non-trivial expression (a Jacobian, a coordinate
transform, a discretization, a likelihood, a change of variables) is derived from a stated starting
point, cited to a specific equation, or built on a postulate the researcher has declared, and it is
checked before it is typed into code. It is not implemented from memory, by analogy to nearby code, or
copied from another codebase without re-deriving for your variables, units, and conventions. The
derivation lives in a comment, a notebook, or a resolvable reference.

The same applies to an experiment's prediction (→ `researcher-in-the-loop`, *Experiments*): the
expected sign, magnitude, or scaling comes from a derivation, a limiting case, or a scaling argument.
A declared postulate is a valid basis for it once the researcher has declared or approved it; a
relation the assistant proposed is not a starting point until then.

A throwaway exploratory calculation (a scaling check in a notebook, a toy integration while developing
a model) may start from a sketch. The derivation is owed before the formula is relied on: merged into
solver code, or used to produce a reported number.

## Before you implement
- **State the starting point**: the governing equation or definition you derive from (B&T 2008
  Eq. 4.x, the Hamiltonian, the DF moment), not a remembered formula. A researcher-original closure is
  a valid starting point once the researcher has declared it: label it a *declared postulate* and
  record it in `assumption-ledger`. It needs no citation, but everything derived from it still gets
  the dimensional and limit checks.
- **Derive or cite to the line**: show the steps (terse is fine) or cite a specific equation in a
  resolvable source. "Standard result" is not a derivation.
- **Dimensional check**: the derived expression has the right units and scaling before it becomes code
  (the symbolic companion to the plausibility envelope, lane 0 of `adversarial-result-check`).
- **Limit check**: it reduces correctly in a limit you can name (isotropic β=0, Newtonian, t→0, r→∞).
- **Then translate**: code it, and keep the derivation beside the implementation so the next reader
  checks code against math.

How much derivation to show (full steps, key steps, or a precise citation) scales with the formula's
subtlety; what has to exist is a checkable line of reasoning. A derived gradient is still grad-checked
rather than eyeballed (→ `gradient-validation`).

## Related
- `provenance` — cite the *numbers*; this derives/cites the *formulas*.
- `numerical-method-validation` — once derived, prove the scheme converges at its order.
- `gradient-validation` — a derived gradient still needs a finite-difference check.
- `adversarial-result-check` — lane 0 is the numeric companion: the derived result must also land at the right order of magnitude.
- `researcher-in-the-loop` — experiments whose predictions this derivation supplies, and which starting assumptions need approval.
- `model-development` — where a declared postulate and its consequences are worked out.
