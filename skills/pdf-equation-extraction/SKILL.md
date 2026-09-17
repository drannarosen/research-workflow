---
name: pdf-equation-extraction
description: Extract implementation-critical equations/coefficients from PDFs, verified. Use when extracting, auditing, or preparing implementation-critical equations, coefficient tables, phase definitions, or derivations from PDFs, especially old, scanned, two-column, or OCR-hostile papers. Don't use for ordinary source summaries, for translating already verified equations into code (→ equation-to-code-traceability), or for licensing questions around reference code (→ reference-license-firewall).
---

Equation-critical papers need more than ordinary literature notes. The rendered PDF or a trusted
publisher view is the source of truth; text extraction, OCR, and model reconstruction are search
aids, because each of them silently drops signs, exponents, and subscripts.

An equation row is implementation-ready only after it has been checked against the rendered source.
A row that came from `pdftotext`, OCR, a model reconstruction, or a reference-code guess stays
`needs-pdf-check` until a human or the verifier agent has compared it with the page image.

## Workflow

1. **Classify the source**: born-digital, scanned, mixed raster/vector, old TeX, two-column, or with
   tables split across pages.
2. **Write an extraction manifest**: PDF path, raw-text path if any, tools used, pages and sections
   checked, and known extraction hazards.
3. **Locate equations by more than one route**: raw text search, table of contents, equation
   numbering, page images, and citation context. No single route is authoritative.
4. **Extract into rows**, each with a stable ID, paper pointer, LaTeX expression, variables, units,
   assumptions and regime, implementation use, and verification state.
5. **Verify row by row** against the rendered page: signs, exponents, subscripts, normalization
   constants, footnotes, table headers, continuation lines, and the definitions near the equation.
6. **Record exclusions**: a row not carried forward is marked `excluded` with the reason.

## Verification states

- `verified`: checked against the rendered PDF or trusted publisher source; ready for specs, tests,
  and code.
- `needs-pdf-check`: a useful draft from extraction or reconstruction; not ready for implementation.
- `not-implementation-ready`: the paper states it correctly, but definitions, closure, regime, or
  context are missing.
- `excluded`: intentionally not carried forward.

## Old-PDF hazards

- Minus signs, hyphens, and overbars are easily confused.
- Primes, superscripts, and subscripts detach from the symbol they modify.
- An equation continued across columns can hide factors or conditions.
- Table coefficients may depend on header rows, footnotes, or a caption on the preceding page.
- OCR swaps Greek and Latin letters (`nu` vs `v`, `rho` vs `p`).
- The PDF viewer's page number may not match the printed page number.
- Reference-code behavior can reveal a missing interpretation, but it is not the paper.

## Where digests live

If the project designates a location for equation digests (for example a `docs/equation-digests/`
folder, or a path named in its CLAUDE.md), write durable digests there and follow any digest command
the project provides. Exact implementation math does not leave the digest for specs, tests, or code
until its rows are `verified`.

Translate verified rows with `equation-to-code-traceability`. When the paper, errata, extraction,
reference code, or implementation disagree, open an entry in `equation-errata-ledger`.

## Related

- `equation-to-code-traceability` - turn verified rows into code, tests, and traceable implementation notes.
- `equation-errata-ledger` - record and resolve contradictions without silently picking a convenient version.
- `reference-license-firewall` - keep paper facts, reference-code behavior, and license-constrained reuse separate.
- `derivation-before-implementation` - general formula gate when the issue is derivation, not PDF extraction.
