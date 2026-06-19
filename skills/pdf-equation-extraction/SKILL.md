---
name: pdf-equation-extraction
description: Use when extracting, auditing, or preparing implementation-critical equations, coefficient tables, phase definitions, or derivations from PDFs, especially old, scanned, two-column, or OCR-hostile papers. Do not use for ordinary source summaries, for already verified equations being translated into code (use equation-to-code-traceability), or for licensing questions around reference code (use reference-license-firewall).
---

Equation-critical papers need a stronger workflow than normal literature notes. The rendered PDF or trusted publisher view is the source of truth; text extraction, OCR, and model reconstruction are search aids only.

## Core rule

An equation row is not implementation-ready until it has been checked against the rendered source. If a row comes from `pdftotext`, OCR, a model reconstruction, or a reference-code guess, mark it `needs-pdf-check` until a human or verifier checks the PDF image.

## Workflow

1. **Classify the source.** Note whether the PDF is born-digital, scanned, mixed raster/vector, old TeX, two-column, or contains tables split across pages.
2. **Create an extraction manifest.** Record PDF path, raw-text path if any, tools used, pages/sections checked, and known extraction hazards.
3. **Locate equations from multiple routes.** Use raw text search, table of contents, equation numbering, PDF page images, and citation context. Never let one route be authoritative by itself.
4. **Extract into rows.** Give each row a stable ID, paper pointer, LaTeX expression, variables, units, assumptions/regime, implementation use, and verification state.
5. **Verify row-by-row.** Compare each row against the rendered PDF. Check signs, exponents, subscripts, normalization constants, footnotes, table headers, continuation lines, and definitions near the equation.
6. **Record exclusions.** If an equation is not carried forward, mark it `excluded` and say why.

## Verification states

- `verified`: checked against the rendered PDF or trusted publisher source; ready for specs/tests/code translation.
- `needs-pdf-check`: useful draft from extraction or reconstruction; not ready for implementation.
- `not-implementation-ready`: correct paper statement but missing definitions, closure, regime, or enough context.
- `excluded`: intentionally not carried forward.

## Old-PDF Edge Cases

- Minus signs, hyphens, and overbars are easily confused.
- Prime marks, superscripts, and subscripts often detach from the symbol they modify.
- Equation continuation across columns can hide factors or conditions.
- Coefficients in tables may depend on header rows, footnotes, or preceding page captions.
- Greek letters and Latin letters can swap in OCR (`nu` vs `v`, `rho` vs `p`).
- Page numbers in the PDF viewer may not match printed page numbers.
- Reference-code behavior can reveal a missing interpretation, but it is not the paper source.

## Brain Integration

When working in Anna's brain repo, follow `.codex/commands/brain-equations.md`. Durable digests belong under `knowledge/derived/equation-digests/`, and exact implementation math should not leave the digest until the relevant rows are `verified`.

Use `equation-to-code-traceability` before translating verified rows into code or tests. Use `equation-errata-ledger` when the paper, errata, extraction, reference code, or implementation disagree.

## Related

- `equation-to-code-traceability` - turn verified rows into code, tests, and traceable implementation notes.
- `equation-errata-ledger` - record and resolve contradictions without silently picking a convenient version.
- `reference-license-firewall` - keep paper facts, reference-code behavior, and license-constrained reuse separate.
- `derivation-before-implementation` - general formula gate when the issue is derivation, not PDF extraction.
