---
name: literature-workflow
description: Use when working with the research literature your project relies on — three modes. INTAKE: read a paper you will rely on into notes that separate its claim, its evidence, and your inference, with page/figure pointers and the regime and caveats. MAP: maintain one living cross-paper map of an area (contributions, method lineages, agreements, contradictions, open gaps). NOVELTY: before investing in a direction, search for the closest existing work from several routes and classify the contribution honestly. Don't use for extracting implementation equations from a PDF (→ pdf-equation-extraction), your own project's assumptions (→ assumption-ledger), or completing a drafted manuscript's citations (use manuscript-workflow lit-scan).
---

What you remember a paper saying drifts from what it showed, and "novel to me" is not "novel to the field." The three modes feed each other: intake notes populate the map, and the map is what a novelty check searches first.

## Intake — reading a paper you will rely on
- **Claim / evidence / your inference, kept apart** → what the paper asserts, what supports it (data, derivation, figure), and your own reading. Conflating them is where misattribution starts.
- **Pointer for every note** → page, section, figure, equation, or table, so it can be re-checked rather than trusted to memory. Implementation-critical equations go to `pdf-equation-extraction`.
- **Regime and caveats** → the conditions the claim holds under, the sample, and the paper's stated weaknesses — exactly what gets dropped when the result is cited later.
- **Your own words, with a trust level** → established, contested, or speculative; note where it disagrees with another paper.

## Map — one living artifact for an area
- Keep **one** map per research area (a table or structured notes in the project, e.g. `docs/literature/`), updated as you read — not a fresh reconstruction per manuscript or proposal.
- Each entry records the work's **actual contribution and where it stops**, not its abstract.
- **The edges are the value** → method lineages, shared datasets, agreeing and conflicting claims. Include the work that contradicts you.
- **Mark the gaps** → unanswered questions and untried combinations feed `research-ideation`.

## Novelty — is this direction already done?
- **Search several routes** → keyword queries in ADS and arXiv, the citation graph of the canonical papers in both directions (ADS `citations()` / `references()`), key authors, and adjacent fields with the same mathematical structure. One database and one query is not a search.
- **Name the 3–5 closest works** → for each, what it did and exactly where it stops.
- **Locate the gap precisely** → new regime, method, dataset, scale, or a contradiction of a prior claim.
- **Classify honestly** → genuinely new / incremental extension / replication / already done. Each is a valid, useful finding.
- **Record the search** → queries, databases, date, closest hits — so the novelty claim is defensible and re-runnable. Breadth scales with commitment: a quick check before a side calculation, an exhaustive sweep before a thesis chapter or proposal.

## Anti-patterns
- "The paper says X," from memory, with no pointer — and it was your inference.
- Citing a result outside the regime the paper established; losing its caveats.
- Declaring novelty after one keyword search; confusing "no one cites these together" with "no one has done it."
- A flat citation list with no relationships, or a map of only favorable work.

## Related
- `pdf-equation-extraction` — the equation-critical specialization of intake.
- `research-ideation` — the map's gaps become candidate directions; novelty is one of its triage axes.
- `research-brainstorming` — sharpen the direction the novelty check cleared.
- `assumption-ledger` — your project's assumptions (a *paper's* regime belongs in intake notes).
- `reference-parity-audit` — when a found work has a reference implementation to compare against.
