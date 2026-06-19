---
name: figure-interpretation-guard
description: Use when drawing a conclusion FROM a figure — yours, a published one, or one an AI/vision model is reading — or when reproducing or comparing figures across papers and runs. Guards against over-reading noise, trends inside unshown uncertainty, log-axis and aspect-ratio illusions, binning/overplotting artifacts, and AI-misread plots; covers like-for-like reproduction/comparison and the provenance of data digitized off a figure. Don't use for whether YOUR figure honestly shows YOUR data (→ plot-faithfulness-inspector), how to design or author it (→ plot-design-inspector / astro-plotting-craft), or general result red-teaming (→ adversarial-result-check).
---

A figure can be perfectly honest and still be misread. Faithfulness is the *maker's* fidelity to the data; interpretation is the *reader's* inference from the picture — and the picture has its own ways of fooling you.

## Reading discipline
- **Separate shown from inferred** → a trend, difference, or correlation seen "by eye" is a hypothesis until checked against the numbers and their uncertainty.
- **Mind the unshown uncertainty** → two curves that "look different" may overlap within error bars the figure omits; don't read a difference the data can't support.
- **Watch the visual traps** → log–log compresses scatter into false tightness; aspect ratio changes perceived slope; truncated ranges exaggerate; binning and smoothing invent or hide structure; overplotting fakes clustering.
- **Don't infer the model from the picture** → a scatter is not causation; an apparent power law on log axes needs a fit and residuals, not eyeballing.

## Reproducing & comparing paper figures
- **Reproduce like-for-like** → match axes, scale, units, ranges, and binning before comparing your result to a published figure; a mismatch is often the axes, not the science.
- **Compare on identical transforms** → overlay or difference only after the same scaling/binning; an apparent discrepancy between two figures is frequently a rendering/binning/colormap/range artifact, not a real disagreement.

## AI-read & digitized figures
- **Distrust AI plot-reading** → a vision model asserting "the trend rises" or reading a value off a plot will hallucinate axes, miss log scales, and invent trends; verify against the underlying data or source (`ai-self-distrust`).
- **Digitization has provenance** → numbers lifted off a published plot (WebPlotDigitizer-style) carry extraction error and need source, method, and uncertainty recorded before any result depends on them (`data-provenance`).

## Related
- `plot-faithfulness-inspector` — the maker-side check that a figure represents the data; this is the reader-side inference.
- `adversarial-result-check` — general red-team of a result; this is the figure-specific reading lens.
- `ai-self-distrust` — applied here to vision models reading plots.
- `reading-notes-discipline` — a figure is evidence in a paper; record what it does and doesn't show.
