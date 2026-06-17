---
name: plot-design-inspector
description: Use when improving a figure's visual design or ideating how best to show a result — chart-type fit for the data and the claim, meaningful color/size/position encoding, decluttering, at-a-glance scientific storytelling, plus a generative mode that proposes 2-3 candidate designs with trade-offs (e.g. profile vs. residual-panel vs. small-multiples for a convergence sweep). Don't use for scientific correctness of the rendered figure (→ plot-faithfulness-inspector) or journal/production code compliance like DPI/fonts/format (→ publication-figure-validator).
---

Inspects and improves how a figure *communicates* — does the chart type, encoding, and layout make the scientific point legible at a glance. Default to critiquing an existing figure; switch to generative mode when given data + the claim but no figure yet.

## Design review checklist
- **Chart-type fit** — does the geometry match the data shape and the claim (trend → line; distribution → hist/violin/ECDF; correlation → scatter; field → heatmap/quiver)? A wrong-type-but-correct figure still fails here.
- **Encoding meaning** — every channel (color, size, position, linestyle) must carry information. Drop decorative ones; map the most important variable to position.
- **Color discipline** — perceptually-uniform sequential/diverging maps for ordered/signed quantities; categorical palettes only for categories; never rainbow for continuous data; check color-blind safety when hue is load-bearing.
- **Declutter** — strip chartjunk, redundant legends, and gridline noise; raise data-ink ratio; prefer direct labeling over a detached legend when traces are few.
- **At-a-glance story** — the intended takeaway should survive a 3-second look. If the reader must hunt, the encoding or annotation is failing.

## Generative mode
Given the data + the point to make, propose **2-3 distinct designs**, each with: the encoding choice, why it serves *this* claim, and its trade-off (what it hides or costs). Bias toward small multiples for parameter sweeps, residual/ratio panels for model-vs-data, and direct annotation of the one feature the figure exists to show.

## Anti-patterns
- Dual y-axes to fake a correlation; stacked areas for non-additive quantities; pie charts for >3 categories.
- Hiding dynamic range with linear axes when the science spans decades (log it, and say so).
- One overplotted panel where small multiples would separate the regimes.
- Encoding the same variable twice (e.g. color *and* size) instead of freeing a channel.

## Related
- `plot-faithfulness-inspector` — does the figure correctly represent the data.
- `publication-figure-validator` — journal/production compliance.
- `testing-strategist` — when planning diagnostic/validation plots before code exists.