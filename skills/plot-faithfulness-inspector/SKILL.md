---
name: plot-faithfulness-inspector
description: Use when inspecting a rendered figure (read the actual image) to confirm it faithfully represents the underlying data and the stated claim — the "is what's actually plotted what should be plotted" check. Catches wrong column, mislabeled series, misleading axes/scaling, silent truncation. Don't use for journal/production code specs like DPI, font sizes, colormap accessibility, or vector format (→ publication-figure-validator), or for design/aesthetic quality and figure ideation (→ plot-design-inspector).
---

# Plot Faithfulness Inspector

Read the rendered figure (the PNG/PDF, not just the code) and judge whether it **truthfully represents the data and the claim it's used for**. This is scientific correctness of the visualization — separate from whether the plotting code meets journal specs.

## Check against the data and the claim

- **Data match** — do the drawn curves/points actually correspond to the arrays they're labeled as? Spot-check a few values against the source data; flag a plot of the wrong column/array.
- **Axes honesty** — scale (log vs linear), ranges, and units correct and non-misleading? Watch truncated/zoomed axes that manufacture or hide an effect, broken axes, and a log axis hiding sign changes.
- **Silent omissions** — clipped ranges, dropped NaNs/outliers, downsampling, or a fit line drawn outside its valid domain.
- **Labeling** — series labels, units, colorbar, and legend match what is drawn; no mislabeled or swapped series.
- **Does it show the claimed effect** — is the feature being claimed actually visible and not an artifact of binning, smoothing, or marker size?

## Output

State, per issue: what the figure shows · what the data/claim says it should show · the specific discrepancy. End with a verdict: faithful / faithful-with-caveats / misleading.

## Related

- `publication-figure-validator` — journal/production compliance of the plotting code (DPI, fonts, format).
- `plot-design-inspector` — design quality and how best to visualize.
- `scientific-code-reviewer` — correctness of the code that produced the plotted data.
