---
name: equation-errata-ledger
description: Use when an equation, coefficient, variable definition, table, erratum, reference implementation, or local test disagrees with another source. Don't use for routine extraction with no contradiction (→ pdf-equation-extraction) or for final code translation once the source is settled (→ equation-to-code-traceability).
---

A contradiction between scientific sources is data. Record the disagreement, keep the evidence, and
mark the implementation status as it actually is, rather than choosing whichever version makes the
code pass.

## When to open an entry

- A paper equation and its coefficient table disagree.
- The rendered PDF and OCR or raw text disagree.
- An erratum, later paper, or code documentation changes a formula.
- Reference code behaves differently from the paper.
- An independent re-derivation finds a sign, factor, exponent, or normalization issue.
- A regression fixture passes under only one interpretation.

## Fields

- `id`: stable conflict ID.
- `topic`: formula, coefficient, phase boundary, unit, table, or algorithm step.
- `sources`: paper equation/page, table/page, erratum, reference-code version, local digest row.
- `candidate_versions`: the competing forms.
- `evidence`: what was checked in the rendered PDF, a code run, or a derivation.
- `decision`: chosen, deferred, excluded, or needs human/domain review.
- `implementation_status`: not-implemented, implemented-with-guard, fixture-only, or blocked.
- `follow_up`: the exact next check.

## Deciding

- Prefer errata or later author corrections that explicitly target the issue.
- Prefer the rendered PDF over raw text extraction.
- Decide **correctness** and **reuse** separately. Correctness comes from derivation, errata, limit
  checks, and tests: prefer paper equations over reference-code internals unless the code is
  demonstrably the published method (e.g. the paper cites it and the paper's own figures reproduce
  from it). The license never decides which formula is right; it only decides whether code may be
  copied (→ `reference-license-firewall`).
- When more than one interpretation remains plausible, block the implementation or guard it behind
  an experimental flag.
- Choosing between candidates that change results is a scientific choice: present the evidence and
  a recommendation, and the researcher decides (→ `researcher-in-the-loop`).
- Keep the losing candidate and the reason it lost.

## Related

- `pdf-equation-extraction` - create source rows and verification states.
- `equation-to-code-traceability` - implement only after the ledger decision is settled.
- `reference-license-firewall` - classify disagreements involving reference code.
- `adversarial-result-check` - stress-test whether a result depends on the disputed interpretation.
