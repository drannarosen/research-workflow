---
name: equation-to-code-traceability
description: Use when translating verified equation-digest rows into code, tests, specs, notebooks, or benchmark fixtures. Don't use to extract equations from PDFs (→ pdf-equation-extraction), to decide reference-code license boundaries (→ reference-license-firewall), or to resolve conflicting sources (→ equation-errata-ledger).
---

Implementation math should be traceable from the source equation to local variables to tests, so a
wrong factor can be found by following the trace rather than by rereading the paper. This starts
once the source rows are `verified` or explicitly `excluded`.

## What the translation carries

- A `needs-pdf-check` row is not implemented as authoritative math.
- Each nontrivial formula in code or tests points to a digest row ID, a paper equation or table, or a
  local derivation note (→ `derivation-before-implementation`).
- Variables are translated explicitly: symbol, local name, units, normalization, domain, and shape.
- Regimes and assumptions survive translation. If an equation holds only for a phase, mass range,
  metallicity range, optical-depth limit, or approximation, that boundary is encoded or tested.
- Coefficients stay traceable: no calibration constant without a source row or provenance note
  (→ `provenance`).

## Steps

1. **Select rows**: the verified digest row IDs, and any rows intentionally excluded.
2. **Map symbols to local names**, with units, dtype expectations, array shape, and package convention.
3. **Propose behavior outside the paper regime**: error, mask, clip, extrapolate with a warning, or
   not supported. This changes what results mean, so it is the researcher's call
   (→ `researcher-in-the-loop`); record the approved choice in `assumption-ledger`.
4. **Implement the smallest checked slice**, narrow enough to compare against hand values or
   published examples.
5. **Write tests beside the translation**: dimensional checks, limit checks, finite examples, and
   regression fixtures when available.
6. **Record the trace** in code comments or docs, citing the digest row ID and paper pointer rather
   than the paper as a whole.

## Output contract

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
- `provenance` - cite source and meaning for numeric constants.
- `numerical-method-validation` - validate numerical schemes built from equations.
- `gradient-validation` - verify autodiff gradients after implementation.
- `reference-license-firewall` - keep reference-code parity checks from becoming unauthorized translation.
