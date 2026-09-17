---
name: astro-plotting-craft
description: Write or audit plotting code in house style (judging a figure → figure-review). Use when writing OR auditing plotting code for astrophysics figures in the plugin's default house style (a project can override it) — AUTHOR mode: the project's theme module or a matplotlib style file as the single source of style, perceptually-uniform colormaps (mako/vlag), CVD-safe categorical palettes with color×marker redundancy, log/linear axis choice, LaTeX (not unicode) labels with CGS/solar units, uncertainty and overlays. AUDIT mode: flag those defects plus broken mathtext in existing code or a rendered figure. Don't use for whether a figure makes its point, honestly shows the data, or licenses a conclusion (→ figure-review).
---

A figure is an argument, and defaults are where it leaks. This skill is the plugin's default house
style for astrophysics figures: the house theme, perceptually uniform color, honest axes, and typeset
math. A project that sets its own figure style (in its CLAUDE.md or a style module) overrides the
theme, palette, and font choices; the color-accessibility, scale, math-typesetting, and uncertainty
rules still apply. Matplotlib defaults and Anthropic orange are not the house style.

## House workflow: define the style once
- **If your project has a theme module, apply it rather than hand-setting rcParams.** (One group uses
  `jaxstroviz`: `set_paper()` / `set_slides()` / `set_poster()` own spines, grid, fonts, and the color
  cycle; `newfig(width=, aspect=)` / `gridfig(nrows, ncols)` size figures; `savefig(fig, path)` saves
  with tight bbox at 300 dpi; accent colors come from `PALETTE`.)
- **Otherwise define the style once in a matplotlib style file** (`.mplstyle`, applied with
  `plt.style.use(...)`) plus a small figure-size helper, and reuse it everywhere. Don't reinvent sizing
  or rcParams per script.
- **Pull accent colors from the theme's named palette**, never literal hexes in figure code. For multiple
  data series, use a CVD-verified cycle with marker/linestyle redundancy (see Color below).

See [references/house-style.md](references/house-style.md) for the default theme and palette spec and
an example theme-module API; seaborn palette/property API is in [references/seaborn-plotting-reference.md](references/seaborn-plotting-reference.md).

## Color (these rules are stricter than the default palette's data cycle — see house-style.md)
- **Continuous → seaborn/perceptually-uniform colormaps**: `mako`/`crest`/`viridis`/`magma` (sequential); diverging `RdBu`/`vlag` (or `sns.diverging_palette(...)`). Never `jet`/`rainbow`/`bwr`, and never a categorical palette as a continuous map.
- **Categorical → house accents from the theme palette**, but for ≥3 series use a **CVD-verified** set (`sns.color_palette("colorblind")`, Wong/Tol) and **compose color with marker/linestyle** — never hue alone. (The default palette's data cycle has a red-green CVD gap; see house-style.md.) `husl` for many categories.
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

## Audit mode (existing code or a rendered figure)
Check the plot against every rule above, plus the defects that only show up in finished code:
- **Broken mathtext** → unbalanced `$`, `$rho$` for `$\rho$`, a non-raw string turning `\t`/`\n` into tab/newline inside a label.
- **Scale mismatch** → linear axis on data spanning decades; log on data that isn't strictly positive; symlog used to hide sign changes.
- **Color** → `jet`/`rainbow`/`hsv`; a qualitative palette as a continuous map; hue-only encoding of ≥3 series; matplotlib default or off-brand colors instead of the theme.
- **Occlusion** → opaque overplotting hiding density; a legend or annotation covering data.
- **Missing** → error bars/bands, units on axes, minor ticks on log axes.

Report per finding: `file:line` (or figure region), the defect, the fix, and severity. Say what is clean rather than inventing problems.

## Related
- `figure-review` — design, faithfulness, and interpretation of the finished figure.
- `provenance` — when plotted data came from an external or digitized source.
