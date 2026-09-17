---
name: figure-review
description: Use when judging a figure rather than writing its code — three modes, picked by the question. DESIGN: does the chart type, encoding, and layout make the point (or propose 2-3 designs for data + claim). FAITHFULNESS: read the rendered image and confirm it shows what the data says (right array, honest axes, no silent clipping). INTERPRETATION: what a figure — yours, a paper's, or one a vision model is reading — actually licenses you to conclude, including like-for-like comparison and digitized values. Don't use for authoring plot code or auditing its craft (log axes, LaTeX labels, colormaps → astro-plotting-craft) or red-teaming a non-figure result (→ adversarial-result-check).
---

A figure can fail three independent ways, and a review that blurs them misses at least one: it can
communicate badly (design), misrepresent the data (faithfulness), or be honestly drawn and still
misread (interpretation). Name the mode you are in; run more than one only when asked or when a
submission-bound figure warrants it.

## Mode 1: Design (does it make the point?)
- **Chart-type fit**: the geometry matches the data and the claim. Trend → line; distribution →
  histogram/ECDF/violin; correlation → scatter; field → image/contour/quiver.
- **Every channel carries information**: position for the most important variable; drop decorative
  color or size; don't encode one variable twice.
- **Declutter**: direct labels over a detached legend when traces are few.
- **3-second test**: the takeaway survives a glance, or the encoding or annotation is failing.
- **Generative** (data + claim, no figure yet): propose 2-3 designs, each with the encoding, why it
  serves this claim, and what it hides. Small multiples for sweeps; residual/ratio panels for model
  vs data.
- Pitfalls: dual y-axes that manufacture a correlation; stacked areas for non-additive quantities;
  one overplotted panel where small multiples would separate regimes.

## Mode 2: Faithfulness (is what's plotted what should be plotted?)
Read the rendered image, not only the code, and review the full plotting function.
- **Data match**: spot-check a few drawn values against the source arrays; catch the wrong column, a
  swapped series, a stale file.
- **Axes honesty**: scale, range, and units; truncated or zoomed ranges that create or hide an effect;
  a log axis concealing sign changes.
- **Silent omissions**: clipped ranges, dropped NaNs or outliers, downsampling, a fit drawn outside
  its valid domain.
- **The claimed effect is visible**, and not an artifact of binning, smoothing, or marker size.
- Output per issue: what the figure shows · what the data says · the discrepancy. Verdict: faithful /
  faithful-with-caveats / misleading.

## Mode 3: Interpretation (what does it license you to conclude?)
- **Shown vs inferred**: a trend seen by eye is a hypothesis until checked against the numbers and
  their uncertainty; curves that "look different" may overlap within error bars the figure omits.
- **Visual traps**: log–log compresses scatter into false tightness; aspect ratio changes perceived
  slope; binning and smoothing invent or erase structure; overplotting fakes clustering. An apparent
  power law needs a fit and residuals.
- **Compare like for like**: match axes, units, ranges, binning, and colormap limits before comparing
  your figure to a published one; most "discrepancies" are rendering, not science.
- **Vision-model readings are unverified**: a model reading a plot can miss log scales, misread axis
  values, and see trends that aren't there; check against the underlying data before relying on it.
- **Digitized values carry provenance**: numbers lifted off a published plot need the source figure,
  the digitization method, and an extraction uncertainty recorded before any result depends on them
  (→ `provenance`).

## Related
- `astro-plotting-craft` — authoring plot code in the house style, and its audit mode for craft defects.
- `adversarial-result-check` — red-team a result that isn't primarily a figure.
- `provenance` — record digitized data like any other external input.
- `literature-workflow` — a figure in a paper is evidence; note what it does and doesn't show.
