---
name: equation-to-code-traceability
description: Use when translating verified equation-digest rows into code, tests, specs, notebooks, or benchmark fixtures. Do not use to extract equations from PDFs (use pdf-equation-extraction), to decide reference-code license boundaries (use reference-license-firewall), or to resolve conflicting sources (use equation-errata-ledger).
---

Implementation math should be traceable from source equation to local variables to tests. This skill starts only after the equation source rows are `verified` or explicitly `excluded`.

## Hard Rules

- Do not implement a `needs-pdf-check` row as authoritative math.
- Each nontrivial formula in code or tests needs a digest row ID, paper equation/table pointer, or a local derivation note.
- Translate variables explicitly. Record symbol, local name, units, normalization, domain, and shape.
- Preserve regimes and assumptions. If a paper equation is valid only for a phase, mass range, metallicity range, optical-depth limit, or approximation, encode or test that boundary.
- Keep coefficients traceable. No naked calibration constants without a source row or provenance note.

## Translation Checklist

1. **Select rows.** List verified digest row IDs and any rows intentionally excluded.
2. **Map symbols to local names.** Include units, dtype expectations, array shape, and package convention.
3. **Choose boundaries.** Decide what happens outside the paper regime: error, mask, clip, extrapolate with warning, or not supported.
4. **Implement the smallest checked slice.** Keep the first translation narrow enough to compare against hand values or published examples.
5. **Write tests beside the translation.** Include dimensional checks, limit checks, finite examples, and regression fixtures when available.
6. **Record the trace.** In code comments or docs, cite the digest row ID and paper pointer, not just the paper as a whole.

## Output Contract

For each implemented formula, leave a compact trace:

```text
digest_row: <bibkey>-<topic>-eqNN
paper_pointer: Eq. <n>, page <p>, section <s>
local_function: package.module.function
variable_map: paper_symbol -> local_name [unit]
tests: test_name::case
status: implemented | deferred | excluded
```

## Related

- `pdf-equation-extraction` - create and verify the digest rows before implementation.
- `provenance-of-constants` - cite source and meaning for numeric constants.
- `numerical-method-validation` - validate numerical schemes built from equations.
- `gradient-validation` - verify autodiff gradients after implementation.
- `reference-license-firewall` - keep reference-code parity checks from becoming unauthorized translation.
