---
name: minimal-falsifiable-slice
description: Bound a test or cutover to the smallest code slice (not exploratory work). Use when you've decided WHAT to change and need to bound it to the smallest code slice that can prove or falsify ONE scientific claim — naming the exact files to touch, the files NOT to touch, and the single run that settles it — instead of a broad multi-purpose rewrite. Applies to test and cutover slices, not to open exploratory work with the researcher. Don't use to design the experiment/decision-rule itself (→ hypothesis-and-test-design), when the real problem is a wrong owner preserved by wrappers (→ correct-cutover), or a confirmed structural mismatch (→ ownership-and-structure).
---

# Minimal falsifiable slice

The experiment is designed and the decision rule is fixed. Bound the code to the smallest slice that
can prove or falsify that one claim: one claim, one knob, the smallest path that settles it. A change
that also touches contracts, reporting, or other physics owners confounds the run, because a result
can no longer be attributed to the one change.

This is for a test slice or a cutover slice. Exploratory work with the researcher (poking at a model,
trying a toy integration, looking at what a diagnostic shows) doesn't need a files-not-to-touch list;
scope it when the exploration turns into a claim to test or an owner to change.

## Slice definition

State these before touching code, merging or reordering rows when the task calls for it:

1. **Claim** being tested (one sentence, falsifiable).
2. **Smallest code path** that affects the claim.
3. **Files to touch** (exact paths).
4. **Files not to touch** (exact paths). Touching one of these confounds the run.
5. **The single run or test** that proves or falsifies the slice.

If a slice cannot be verified directly by that run, it is too large or too vague.

## Worked slice

> **Claim:** the flat ~1e-3 energy error in a 1000-body Plummer run comes from the energy *diagnostic*
> using the unsoftened potential −Gm/r while the forces use the softened kernel −Gm/√(r²+ε²), not from
> integrator truncation.
>
> **Smallest code path:** the potential-energy term in the energy diagnostic.
>
> **Touch:** the diagnostic's potential function (e.g. `src/<pkg>/diagnostics/energy.py`) and one new
> validation test.
>
> **Do not touch:** the integrator, the force kernel, the softening value, the IC sampler. Changing any
> of these alters the dynamics and confounds the test.
>
> **Single check:** recompute E with the softened kernel on the snapshots of the existing runs at
> Δt₀, Δt₀/2 and Δt₀/4 (the Δt sweep that showed the error is flat). If |ΔE/E| drops to the
> integrator's level and now scales as Δt² across the three steps (2nd-order leapfrog), the claim
> holds; if the Δt-independent ~1e-3 persists, the diagnostic is not the owner and the claim is
> falsified.

The slice changes one owner (the diagnostic) and reuses existing runs. The dynamics stay untouched, so the
result is unambiguous.

## Scope pitfalls
- Changing contracts, reporting, and physics owners in one patch.
- Adding diagnostic infrastructure before the core owner change exists.
- Cleanup folded into the slice. Keep owner rewrites separate from broad cleanup unless the rewrite
  requires it, and leave "while I'm here" changes for their own commit.

## Related

- `hypothesis-and-test-design` — design the test (observable + decision rule) the slice is built to run; come here after.
- `verification-gate` — the slice must end in a falsifiable pass/fail.
- `ownership-and-structure` / `correct-cutover` — when "small" isn't the issue; the owner is.
- `superpowers:writing-plans` / `superpowers:test-driven-development` (other plugin) — once the slice is bounded, hand off to build it test-first.
