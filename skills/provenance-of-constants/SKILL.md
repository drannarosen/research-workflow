---
name: provenance-of-constants
description: Use when writing or reviewing solver code that hardcodes physical constants, empirical coefficients, or formulas (G, softening scales, mass-radius fit coefficients, opacity tables) — gate that every magic number carries a provenance comment citing its authority (CODATA/IAU constant, the fit paper, the equation reference) before it ships. Don't use for the astrophysics constant VALUES themselves (those live in your project's constants module, not here) or for general per-command evidence discipline (→ evidence-first-execution).
---

Every constant, coefficient, and formula in the code must trace to a cited authority. A number you can't cite is a number you can't trust — this is the no-fabrication rule applied to numerics. Default: flag any literal that isn't a trivial mathematical constant (0, 1, 2, π) or a documented tolerance and demand a provenance comment before merge.

## Provenance checklist
Every non-trivial literal must answer "where did this come from?" in a comment at its definition:
- **Physical constant** → cite the standard body + epoch (e.g. `# CODATA 2018`, `# IAU 2015 nominal`). Name the value, don't just inline it.
- **Empirical coefficient / fit** → cite the paper, table, and equation *with a resolvable identifier* (DOI, arXiv id, or ADS bibcode) alongside author-year, so a reader can pull the source — e.g. `# Tout et al. 1996, MNRAS 281, 257, Table 1 (arXiv:astro-ph/9609104)` or `# Eggleton 1983, ApJ 268, 368, Eq. 2 (1983ApJ...268..368E)`. Fit coefficients travel as a labeled block, never scattered.
- **Formula / scheme** → cite the reference it implements with a resolvable id (e.g. `# Yoshida 1990, Phys. Lett. A 150, 262 — 4th-order symplectic coeffs`), so a reader can check the implementation against the source.
- **Tuned / chosen value** (softening length, timestep floor, tolerance) → state it's a choice and why, not a derived fact; record the rationale in the decision log — e.g. `# collisionless softening ε ≈ 0.05·d_mean; gravax convention (CLAUDE.md), prevents fixed-timestep singularities` or `# η < 0.01 PEFRL timestep, gravax recommended setting for |ΔE/E| < 1e-4`.

## Anti-patterns
- A bare literal mid-expression (`* 3.828e33`) with no comment — even if correct, it's unauditable.
- Citing "standard value" or "textbook" with no specific source, edition, or epoch.
- Copying a coefficient block from another package without carrying its citation forward.
- Silently changing a constant's precision or epoch (CODATA 2014 → 2018) without noting it — a reproducibility break.

## Hard vs adaptable

- **Hard rule:** the provenance comment *exists* at the literal's definition. A non-trivial number with no citation does not ship — this is the no-fabrication rule, non-negotiable.
- **Adaptable:** the citation format and which resolvable id you use (DOI vs arXiv vs ADS bibcode). Match the package's convention; what must survive is *specific + resolvable*, not a fixed template.

This skill demands the citation *exists and is specific*; it does not adjudicate the value — that lives in `astro-code-dev` (other plugin).

## Related
- `astro-code-dev` (other plugin) — the cited constant/coefficient values for the gravax/stellax stack (the facts).
- `evidence-first-execution` — provenance is the constants-facet of evidence-first discipline.
- `decision-log-and-commits` — record the source when a constant/coefficient choice is made.