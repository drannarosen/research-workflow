# House style spec (Anna / jaxstro family)

The canonical implementation lives in the **jaxstroviz** package (`src/jaxstroviz/styles/`). Skills
**reference** it — apply its themes, size with its figure helpers, and pull colors from `PALETTE` /
`COLOR_CYCLE`; never hardcode hexes in figure code. This doc describes jaxstroviz **as it is today** and
names the SoTA upgrade targets (the skills enforce the stricter color rules regardless).

## Current jaxstroviz styling — use as-is

**Themes** (`styles/themes.py`): `set_paper(light=True)` / `set_slides()` / `set_poster()` + context
managers (`paper_theme()` …) + `reset_theme()`.

| Theme | Font | Base size | Figsize | Lines |
|---|---|---|---|---|
| `paper` (+ `light=False` dark variant) | serif / Computer Modern Roman, `mathtext.fontset=cm` | 8 pt (title 9, ticks 7) | 3.35×2.5″ | 1.0 |
| `slides` | sans (Helvetica/Arial/DejaVu Sans) | 14 pt | 10×6″ | 2.5 |
| `poster` | sans | 18 pt | 12×8″ | 3.0 |

**Shared base rcParams:** white bg; dpi 100 screen / **300 + tight bbox** on save (`pad 0.05`); ink
`#1f2937` for text/axes/ticks; **top/right spines off**; grid off by default (`#e5e7eb`, α 0.7 when on);
ticks `out`; `axes.linewidth 0.8`; legend `frameon=False`; cycle = `COLOR_CYCLE`.

**Figure helpers** (`styles/figures.py`): `newfig(width=, aspect=, nrows=, ncols=)`,
`gridfig(nrows, ncols, width=)`, `savefig(fig, path, dpi=300)`, `close()`, `to_numpy()`.
Widths: `PAPER_WIDTH_SINGLE` 3.35″, `PAPER_WIDTH_DOUBLE` 7.0″, `SLIDES_WIDTH` 10″, `POSTER_WIDTH` 12″.

**Palette** (`styles/palette.py`, currently blue-led): `primary #2563eb`, `secondary #7c3aed`,
`accent #0891b2`; semantic `success #059669` / `warning #d97706` / `error #dc2626`; neutrals
`dark #1f2937` / `medium #6b7280` / `light #e5e7eb` / `background #f9fafb`; astro `star_hot #60a5fa` /
`star_warm #fbbf24` / `star_cool #ef4444` / `gas #34d399` / `dust #a78bfa`; `COLOR_CYCLE` = data1–6
(`#2563eb`,`#dc2626`,`#059669`,`#d97706`,`#7c3aed`,`#0891b2`); legacy `teal #14b8a6`. Helpers
`get_color()`, `MARKER_CYCLE`, `LINE_CYCLE`. **Verdict: the themes/architecture are strong (near-SoTA) —
keep verbatim.**

## SoTA gaps — "do better" (upgrade targets for jaxstroviz; the skills already enforce these)

1. **CVD-safe categorical palette (highest impact).** `COLOR_CYCLE` is labelled colorblind-friendly but
   isn't — `data2 #dc2626` (red) and `data3 #059669` (green) are adjacent, the canonical
   deuteranopia/protanopia failure. Replace with a simulator-verified set: Wong 2011 (Nat. Methods),
   Tol, or `sns.color_palette("colorblind")`.
2. **Compose color × marker/linestyle.** `MARKER_CYCLE`/`LINE_CYCLE` exist but aren't wired into
   `axes.prop_cycle`, so series rely on hue alone (fails in grayscale/CVD). Build a composed cycler.
3. **Reproducible fonts.** `font.serif: ["Computer Modern Roman", …]` silently falls back to DejaVu
   Serif on machines without CM installed → figures differ across machines. Use `usetex` (opt-in) or a
   bundled serif TTF (STIX/DejaVu) so it's machine-independent.
4. **Perceptually-uniform colormap policy.** No house sequential/diverging default is set, and custom
   `jaxstro_*` maps risk non-uniformity (Crameri 2020). Set sequential = `viridis`/`mako`,
   diverging = `RdBu`/`vlag`/Crameri `vik`; ban `jet`/`rainbow`/`bwr`; retire non-uniform custom maps.
5. **Minor.** Enable minor ticks on log axes; consider `constrained_layout`.

## Optional aesthetic (deferred, not required)
A teal-led "Teal Synthwave" refresh (deep teal `#0F766E` lead, Inter for slides, seaborn colormaps) was
prototyped and liked — preview regenerable from `/tmp/teal_synthwave_preview.py`. It's a **preference**,
orthogonal to the SoTA fixes above; apply in jaxstroviz whenever desired (the skills auto-follow because
they reference `PALETTE`/`COLOR_CYCLE`, not hardcoded hexes).

## jaxstroviz API map (what the authoring skill teaches)
- **Theme:** `set_paper(light=True)` / `set_slides()` / `set_poster()` + context managers; `reset_theme()`.
- **Figures:** `newfig`, `gridfig`, `savefig`, `close`, `to_numpy`; the width constants above.
- **Color:** `PALETTE`, `get_color(name)`, `COLOR_CYCLE`, `MARKER_CYCLE`, `LINE_CYCLE`.

## Axis & scale conventions (astro)
Density/IMF/mass functions `loglog`; energy/virial drift `semilogy`; velocity dispersion `semilogx`.
Units in brackets, LaTeX only: `r"$r$ [pc]"`, `r"$\rho$ [M$_\odot$ pc$^{-3}$]"`, `[km/s]`, `r"$\Delta E/E$"`.
