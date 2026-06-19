---
name: astro-plotting-craft
description: Use when writing plotting code for astrophysics figures — author publication-grade plots in the house style: the jaxstroviz theme/helpers as source of truth, seaborn perceptually-uniform colormaps (mako/vlag), CVD-safe categorical palettes with color×marker redundancy, log/linear axis choice, LaTeX (not unicode) labels with CGS/solar units, uncertainty/overlays. Don't use to audit an existing figure's craft (→ plot-craft-reviewer), what a figure lets you conclude (→ figure-interpretation-guard), whether it honestly shows the data (→ plot-faithfulness-inspector), chart-type/design ideation (→ plot-design-inspector), or journal submission specs (→ publication-figure-validator).
---

A figure is an argument, and defaults are where the argument leaks. The reflex is matplotlib defaults and Anthropic-orange — neither is the house style. Plot like an expert astrophysicist: the house theme, perceptually-uniform color, honest axes, and typeset math.

## House workflow — jaxstroviz is the source of truth
- **Apply the theme, don't hand-set rcParams** → `set_paper()` / `set_slides()` / `set_poster()` from `jaxstroviz` own spines, grid, fonts, and the color cycle.
- **Size with the helpers** → `newfig(width=, aspect=)`, `gridfig(nrows, ncols)`; save with `savefig(fig, path)` (tight bbox, 300 dpi). Don't reinvent figure sizing.
- **Pull brand colors from `PALETTE` / `COLOR_CYCLE`**, never literal hexes.

See [references/house-style.md](references/house-style.md) for the palette spec and the jaxstroviz API map; seaborn palette/property API is in [references/seaborn-plotting-reference.md](references/seaborn-plotting-reference.md).

## Color (these rules are stricter than jaxstroviz's current cycle — see house-style.md)
- **Continuous → seaborn/perceptually-uniform colormaps**: `mako`/`crest`/`viridis`/`magma` (sequential); diverging `RdBu`/`vlag` (or `sns.diverging_palette(...)`). Never `jet`/`rainbow`/`bwr`, and never a categorical palette as a continuous map.
- **Categorical → pull house colors from jaxstroviz `PALETTE`/`COLOR_CYCLE`**, but for ≥3 series use a **CVD-verified** set (`sns.color_palette("colorblind")`, Wong/Tol) and **compose color with marker/linestyle** — never hue alone. (jaxstroviz's current cycle has a red-green CVD gap; see house-style.md.) `husl` for many categories.
- Verify against a colorblind simulator when color is load-bearing.

## Axes & scale
- **Choose scale from the data**: log for power laws, many decades, or positive multiplicative ranges (`loglog`, `semilogy`); linear otherwise. Don't default to linear out of habit.
- Label every axis with **units in brackets**; add minor ticks on log axes.

## Typography & math
- Math and units are **LaTeX/mathtext, never unicode**: `r"$M_\odot$"`, `r"$\mathrm{erg\,s^{-1}}$"`, `r"$\rho$"` — not `M☉`, `ρ`, `erg/s`. Always use raw strings (`r"..."`).
- The theme sets the fonts (serif/Computer Modern for paper, sans for slides/poster); for reproducibility prefer a bundled/`usetex` serif over relying on a system "Computer Modern Roman" install (see house-style.md).

## Uncertainty & overlays
- **Show uncertainty** — error bars or `fill_between` bands; a point estimate with no error is a claim without a bar.
- **Beat overplotting** — alpha, 2D histogram / `hexbin` / datashader for dense scatter; don't dump 10⁵ opaque points.
- Legends `frameon=False`, placed off the data; annotate sparingly.

## seaborn objects (optional — layered/exploratory)
- `so.Plot(df, x=, y=).add(so.Dot()).add(so.Line())` with `so.Nominal`/`so.Continuous` scales (properties in the reference). Use for faceting/layering; classic matplotlib + the theme for final publication figures.

## Related
- `plot-craft-reviewer` — audits a finished plot for the defects this skill prevents.
- `plot-design-inspector` — which chart and composition best tell the story.
- `figure-interpretation-guard` — what a finished figure does and doesn't license you to conclude.
- `publication-figure-validator` — journal DPI/font/format compliance at submission.
