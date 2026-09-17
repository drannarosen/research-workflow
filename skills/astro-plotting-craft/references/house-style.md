# House style spec (default theme and palette)

This is the plugin's default figure style. Define it **once** — in your project's theme module if it has
one, otherwise in a matplotlib style file (`.mplstyle`) plus a small figure-size helper — and have figure
code apply the theme, size with the helper, and pull colors from a named palette. Never hardcode hexes in
figure code. (One group implements this style in a theme package, `jaxstroviz`; its API is mapped at the
end as an example.) The SoTA upgrade targets below are enforced by the skill regardless of which palette
a project ships.

## Default themes

| Theme | Font | Base size | Figsize | Lines |
|---|---|---|---|---|
| `paper` (+ dark variant) | serif / Computer Modern Roman, `mathtext.fontset=cm` | 8 pt (title 9, ticks 7) | 3.35×2.5″ | 1.0 |
| `slides` | sans (Helvetica/Arial/DejaVu Sans) | 14 pt | 10×6″ | 2.5 |
| `poster` | sans | 18 pt | 12×8″ | 3.0 |

**Shared base rcParams:** white bg; dpi 100 screen / **300 + tight bbox** on save (`pad 0.05`); ink
`#1f2937` for text/axes/ticks; **top/right spines off**; grid off by default (`#e5e7eb`, α 0.7 when on);
ticks `out`; `axes.linewidth 0.8`; legend `frameon=False`; cycle = the palette's data cycle.

**Figure widths:** paper single column 3.35″, paper double column 7.0″, slides 10″, poster 12″.

## Default palette

Blue-led: `primary #2563eb`, `secondary #7c3aed`, `accent #0891b2`; semantic `success #059669` /
`warning #d97706` / `error #dc2626`; neutrals `dark #1f2937` / `medium #6b7280` / `light #e5e7eb` /
`background #f9fafb`; astro `star_hot #60a5fa` / `star_warm #fbbf24` / `star_cool #ef4444` /
`gas #34d399` / `dust #a78bfa`; data cycle data1–6 (`#2563eb`,`#dc2626`,`#059669`,`#d97706`,`#7c3aed`,
`#0891b2`); legacy `teal #14b8a6`. Companion marker and linestyle cycles. **The theme architecture is
strong (near-SoTA) — keep it; fix the data cycle per the gaps below.**

## SoTA gaps — "do better" (upgrade targets; the skill already enforces these)

1. **CVD-safe categorical palette (highest impact).** The data cycle above is often labelled
   colorblind-friendly but isn't — `data2 #dc2626` (red) and `data3 #059669` (green) are adjacent, the
   canonical deuteranopia/protanopia failure. Replace with a simulator-verified set: Wong 2011
   (Nat. Methods), Tol, or `sns.color_palette("colorblind")`.
2. **Compose color × marker/linestyle.** Marker and linestyle cycles that aren't wired into
   `axes.prop_cycle` leave series relying on hue alone (fails in grayscale/CVD). Build a composed cycler.
3. **Reproducible fonts.** `font.serif: ["Computer Modern Roman", …]` silently falls back to DejaVu
   Serif on machines without CM installed → figures differ across machines. Use `usetex` (opt-in) or a
   bundled serif TTF (STIX/DejaVu) so it's machine-independent.
4. **Perceptually-uniform colormap policy.** Set a house sequential/diverging default, and avoid custom
   maps that risk non-uniformity (Crameri 2020). Sequential = `viridis`/`mako`,
   diverging = `RdBu`/`vlag`/Crameri `vik`; ban `jet`/`rainbow`/`bwr`; retire non-uniform custom maps.
5. **Minor.** Enable minor ticks on log axes; consider `constrained_layout`.

## Optional aesthetic (not required)
A teal-led variant (deep teal `#0F766E` lead, Inter for slides, seaborn colormaps) is a **preference**,
orthogonal to the SoTA fixes above. Because figure code references the named palette rather than hexes,
changing the palette in one place restyles every figure.

## Example theme-module API (jaxstroviz)
- **Theme:** `set_paper(light=True)` / `set_slides()` / `set_poster()` + context managers
  (`paper_theme()` …); `reset_theme()`.
- **Figures:** `newfig(width=, aspect=, nrows=, ncols=)`, `gridfig(nrows, ncols, width=)`,
  `savefig(fig, path, dpi=300)`, `close()`, `to_numpy()`; width constants `PAPER_WIDTH_SINGLE`,
  `PAPER_WIDTH_DOUBLE`, `SLIDES_WIDTH`, `POSTER_WIDTH`.
- **Color:** `PALETTE`, `get_color(name)`, `COLOR_CYCLE`, `MARKER_CYCLE`, `LINE_CYCLE`.

Without a theme module, the same shape is a `house.mplstyle` holding the rcParams above, a
`newfig(width, aspect)` helper, and a `PALETTE` dict.

## Axis & scale conventions (astro)
Density/IMF/mass functions `loglog`; energy/virial drift `semilogy`; velocity dispersion `semilogx`.
Units in brackets, LaTeX only: `r"$r$ [pc]"`, `r"$\rho$ [M$_\odot$ pc$^{-3}$]"`, `[km/s]`, `r"$\Delta E/E$"`.
