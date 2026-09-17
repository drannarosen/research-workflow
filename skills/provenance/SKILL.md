---
name: provenance
description: Use when a number or input enters research code from somewhere — a hardcoded physical constant, empirical fit coefficient, or implemented formula in source (G, opacity tables, mass-radius fits, integrator coefficients), or an external dataset, catalog, lookup grid, or checkpoint the code reads — so each carries its origin: a resolvable citation (or a labeled declared postulate) for in-code values, and source + version/release + checksum for data files. Pairs with the provenance.sh hook. Don't use for the constant VALUES themselves (→ astro-code-dev, other plugin), logging which inputs a run used (→ run-reproducibility), or why a tuned value was chosen (→ decision-log-and-commits).
---

A number you can't trace is a number you can't defend. Two kinds enter research code: values written **in the source**, and data files read **from outside**. Both need their origin recorded where they are defined.

## In-code constants, coefficients, formulas
Comment at the definition:
- **Physical constant** → standard body + epoch (`# CODATA 2018`, `# IAU 2015 nominal`); name it, don't inline `* 3.828e33`.
- **Empirical fit coefficient** → paper, table, equation, and a resolvable id (DOI, arXiv, or ADS bibcode): `# Tout et al. 1996, MNRAS 281, 257, Table 1 (arXiv:astro-ph/9609104)`. Coefficient blocks travel together with their citation.
- **Formula or scheme** → the reference it implements, resolvable: `# Yoshida 1990, Phys. Lett. A 150, 262 — 4th-order symplectic coefficients`.
- **Declared postulate** → a coefficient of the researcher's own closure: `# declared postulate: drag threshold v_c (researcher model; assumption-ledger A3)`. No literature citation needed; don't swap in a published value.
- **Tuned choice** (softening, timestep floor, tolerance) → say it is a choice and why.
- **Not flagged:** pure mathematical factors (½ in ½mv², 4/3 and 3/(4π), π), integer counts and shapes, documented numerical tolerances.
- Changing a constant's epoch (CODATA 2014 → 2018) is a reproducibility break — note it.

## External data inputs
In committed metadata (a `data/SOURCES.md`, a checksum sidecar, or a loader that asserts the hash):
- **Source** → URL, DOI, archive record, survey release page, or the script that generated it. "From a colleague" is not a source.
- **Version / release** → `Gaia DR3`, not "Gaia"; a table revision or checkpoint tag. "Latest" is not a version.
- **Checksum** → sha256 next to the path, so a truncated, re-downloaded, or silently re-released file is caught.
- **Access date** for sources without immutable versions; **license / citation terms** where redistribution is restricted.
- Derived data points back to its raw inputs and the transform that made it.

## Anti-patterns
- "Standard value" or "textbook" with no source, edition, or epoch.
- A coefficient block copied from another package without its citation.
- A hardcoded path no manifest explains (`/scratch/me/v2_final_FINAL.h5`).
- A checkpoint loaded by filename with no record of what produced it.

## Related
- `astro-code-dev` (other plugin) — the cited values themselves for the gravax/stellax stack.
- `run-reproducibility` — a run's config points at the dataset version and hash recorded here.
- `assumption-ledger` — where declared postulates are recorded.
- `decision-log-and-commits` — the rationale for tuned choices.
