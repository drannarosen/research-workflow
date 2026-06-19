---
name: reading-notes-discipline
description: Use when reading papers whose content you will rely on — extract claims, evidence, assumptions, and caveats into structured notes in your own words, with page/figure pointers, so you don't misremember or misattribute what a source actually established. Don't use for extracting implementation equations/coefficients from a PDF (→ pdf-equation-extraction), maintaining the cross-paper field map (→ related-work-map), a one-time novelty check (→ prior-art-check), or recording your own project's assumptions (→ assumption-ledger).
---

What you remember a paper saying drifts from what it showed. Reliable research rests on notes that separate a paper's actual claim from its evidence from your own inference about it — each with a pointer back to where it lives, so a citation can be re-checked rather than trusted to memory.

## Discipline
- **Separate claim / evidence / your inference** → record what the paper asserts, what supports it (data, derivation, figure), and your own reading as three distinct things; conflating them is where misattribution starts.
- **Point back to the source** → page, section, figure, equation, or table for each note, so the claim is re-checkable. Implementation-critical equations hand off to `pdf-equation-extraction`.
- **Note the regime and caveats** → the conditions under which the claim holds, the sample or limits, and the paper's stated weaknesses — exactly the parts dropped when the result is cited later.
- **Write in your own words** → a paraphrase you can defend beats a highlighted quote; copying risks both silent error and plagiarism.
- **Flag trust level** → distinguish established results, contested claims, and your own speculation; record where a paper disagrees with another (→ related-work-map, `equation-errata-ledger`).

## Anti-patterns
- "The paper says X," from memory and with no pointer, that turns out to be your inference.
- Citing a result outside the regime the paper actually established.
- Highlighting or quoting instead of restating, so the claim's meaning is never tested.
- Losing the caveats — citing a tentative or bounded result as settled.
- Treating reference-code behavior as if it were a paper claim.

## Hard vs adaptable
- **Hard rule:** a note you will cite separates the paper's claim from its evidence and carries a source pointer; no claim is asserted from memory.
- **Adaptable:** note depth and format scale to how load-bearing the source is.

## Related
- `related-work-map` — per-paper notes aggregate into the cross-paper field map.
- `pdf-equation-extraction` — the equation-critical specialization for implementation math.
- `prior-art-check` — uses these notes to judge novelty and closest work.
- `assumption-ledger` — your project's assumptions; this captures the sources behind them.
