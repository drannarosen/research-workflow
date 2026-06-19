---
name: equation-errata-ledger
description: Use when an equation, coefficient, variable definition, table, erratum, reference implementation, or local test disagrees with another source. Do not use for routine extraction with no contradiction (use pdf-equation-extraction) or for final code translation once the source is settled (use equation-to-code-traceability).
---

Contradictions in scientific sources are data, not nuisances. Do not silently choose the version that makes the code pass. Record the disagreement, preserve the evidence, and mark implementation status honestly.

## When To Open A Ledger Entry

- Paper equation and coefficient table disagree.
- Printed PDF and OCR/raw text disagree.
- Erratum, later paper, or code documentation changes a formula.
- Reference code behavior differs from the paper.
- Independent re-derivation finds a sign, factor, exponent, or normalization issue.
- A regression fixture passes only under one interpretation.

## Ledger Fields

Use a compact table or section with:

- `id`: stable conflict ID.
- `topic`: formula, coefficient, phase boundary, unit, table, or algorithm step.
- `sources`: paper equation/page, table/page, erratum, reference-code version, local digest row.
- `candidate_versions`: the competing forms.
- `evidence`: what was checked in the rendered PDF, code run, or derivation.
- `decision`: chosen, deferred, excluded, or needs human/domain review.
- `implementation_status`: not-implemented, implemented-with-guard, fixture-only, or blocked.
- `follow_up`: exact next check.

## Decision Discipline

- Prefer errata or later author corrections when they explicitly target the issue.
- Prefer rendered PDF over raw text extraction.
- Prefer paper equations over reference-code internals unless the code is the published method and its license permits reuse.
- If multiple interpretations remain plausible, mark the implementation blocked or guard it behind an experimental flag.
- Keep both the losing candidate and the reason it lost.

## Related

- `pdf-equation-extraction` - create source rows and verification states.
- `equation-to-code-traceability` - implement only after the ledger decision is settled.
- `reference-license-firewall` - classify disagreements involving reference code.
- `adversarial-result-check` - stress-test whether a result depends on the disputed interpretation.
