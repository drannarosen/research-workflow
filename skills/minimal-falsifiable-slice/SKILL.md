---
name: minimal-falsifiable-slice
description: Use when you've decided WHAT to change and need to bound it to the smallest code slice that can prove or falsify ONE scientific claim — naming the exact files to touch, the files NOT to touch, and the single run that settles it — instead of a broad multi-purpose rewrite. Don't use to design the experiment/decision-rule itself (→ discriminating-experiment-design), when the real problem is a wrong owner preserved by wrappers (→ correct-cutover), or a confirmed structural mismatch (→ ownership-and-structure).
---

# Minimal Falsifiable Slice

## Overview

The experiment is designed and the decision rule is fixed. Now bound the *code* to the smallest slice that can prove or falsify that ONE claim — and no more.

## Required slice definition

State all five before touching code:

1. **Claim** being tested (one sentence, falsifiable)
2. **Smallest code path** that affects the claim
3. **Files to touch** (exact paths)
4. **Files NOT to touch** (exact paths — the guardrail against scope creep)
5. **The single run/test** that proves or falsifies the slice

## Worked slice

> **Claim:** the flat ~1e-3 energy error in a 1000-body Plummer run comes from the energy *diagnostic* using the unsoftened potential −Gm/r while the forces use the softened kernel −Gm/√(r²+ε²) — not from integrator truncation.
>
> **Smallest code path:** the potential-energy term in the energy diagnostic.
>
> **Touch:** the diagnostic's potential function (e.g. `src/<pkg>/diagnostics/energy.py`) and one new validation test.
>
> **Do NOT touch:** the integrator, the force kernel, the softening value, the IC sampler. Changing any of these alters the dynamics and confounds the test.
>
> **Single run:** no new integration — recompute E on the *existing* snapshots with the softened kernel. If |ΔE/E| drops to the integrator's level and now scales as Δt² across a {Δt, Δt/2} pair (2nd-order leapfrog), the claim holds; if the flat 1e-3 persists, the diagnostic is not the owner and the claim is falsified.

The slice changes one owner (the diagnostic) and needs no rerun — the dynamics stay untouched, so the result is unambiguous.

## Rules

1. Do not mix owner rewrites with broad cleanup unless required.
2. Do not add "while I'm here" changes.
3. If a slice cannot be verified directly, it is too large or too vague.

## Hard vs adaptable

- **Hard rule:** slice size — one claim, one knob, the smallest path that settles it. The "files NOT to touch" list is the enforceable guardrail; violating it confounds the run.
- **Adaptable scaffold:** the 5-row definition. Merge or reorder rows to fit the task; the constraint that survives is *minimal + falsifiable*, not the exact form.

## Anti-patterns

- changing contracts, reporting, and physics owners in one unscoped patch
- adding diagnostic infrastructure before the core owner change exists
- broad cleanup disguised as scientific progress

## Related

- `discriminating-experiment-design` — design the test (observable + decision rule) the slice is built to run; come here after.
- `verification-gate` — the slice must end in a falsifiable pass/fail.
- `ownership-and-structure` / `correct-cutover` — when "small" isn't the issue; the owner is.
- `superpowers:writing-plans` / `superpowers:test-driven-development` (other plugin) — once the slice is bounded, hand off to build it test-first.
