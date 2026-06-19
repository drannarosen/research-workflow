---
description: Build or review an implementation-ready equation digest from source PDFs, with rendered-PDF verification states, traceability, license/firewall notes, and errata/conflict handling.
argument-hint: "<bibkey|pdf|digest path> [scope]"
---
Create or review an equation digest for: $ARGUMENTS

This is the deterministic entry point for equation-critical sources. Apply the workflow in order; do not treat raw text extraction as authoritative.

1. Invoke `pdf-equation-extraction` to classify the source, create/update the extraction manifest, and draft rows with honest verification states.
2. If rows are being marked `verified`, invoke the `equation-verifier` agent to check them against the rendered PDF or trusted publisher source.
3. If the digest will feed code, tests, fixtures, or specs, invoke `equation-to-code-traceability` and require row IDs, variable maps, units, assumptions, and target tests.
4. If reference implementations are involved, invoke `reference-license-firewall` before reading source code as anything more than an oracle or behavior guide.
5. If paper, erratum, extraction, reference code, or local tests disagree, open/update an `equation-errata-ledger` entry instead of silently choosing.

Required output:

- Source files checked and page/section scope.
- Row counts by state: `verified`, `needs-pdf-check`, `not-implementation-ready`, `excluded`.
- Rows that must not be implemented yet.
- Traceability and firewall notes if implementation or reference parity is in scope.
- Exact next verification checks.
