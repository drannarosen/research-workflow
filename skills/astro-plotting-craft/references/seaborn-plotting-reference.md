# seaborn plotting reference (distilled)

Distilled from the seaborn docs to reduce API drift. Sources:
<https://seaborn.pydata.org/tutorial/color_palettes.html> and
<https://seaborn.pydata.org/tutorial/properties.html> (verify against the installed seaborn version).

## Palettes — `sns.color_palette(palette, n_colors=None, desat=None, as_cmap=False)`
- `set_palette(...)` sets the default with the same args.
- `as_cmap=True` → continuous matplotlib colormap; otherwise a discrete list.

**Qualitative / categorical:** `"deep"` (default), `"muted"`, `"pastel"`, `"bright"`, `"dark"`, `"colorblind"`, `"tab10"`, `"Set2"`, `"Paired"`.
- Circular systems for arbitrary N: `"hls"` (equal-saturation RGB) and **`"husl"`** (HSLuv — more perceptually even luminance around the wheel; preferred for many categories).

**Sequential, perceptually uniform:** `"rocket"`, `"mako"`, `"flare"`, `"crest"`, plus `"magma"`, `"viridis"`.
- `cubehelix_palette(start=, rot=, dark=, light=, reverse=, as_cmap=)`, or string form `color_palette("ch:start=.2,rot=-.3", as_cmap=True)` / shorthand `"ch:s=-.2,r=.6"`.
- `light_palette(color)` / `dark_palette(color)`, or `color_palette("light:<color>")` / `color_palette("dark:<color>")` (`reverse=True` to flip).

**Diverging, perceptually uniform:** `"vlag"`, `"icefire"`.
- `diverging_palette(hue_1, hue_2, s=, l=, sep=, center="light"|"dark", as_cmap=)` — custom HUSL diverging (e.g. on-brand teal↔pink `diverging_palette(180, 330, as_cmap=True)`).

**When to use which:** qualitative = categories (cap the count; pair hue with shape for colorblind safety); sequential = ordered magnitude (luminance carries the structure); diverging = numeric data with a meaningful center. Avoid red-green; check against colorblind simulation.

## Objects interface — `so.Plot(data, x=, y=).add(mark, ...)`
Marks: `so.Dot`, `so.Dots`, `so.Line`, `so.Lines`, `so.Path`, `so.Area`, `so.Band`, `so.Bar`, `so.Bars`, `so.Range`, `so.Text`. Layer with chained `.add()`; `.facet()`, `.pair()`, `.scale()`, `.theme()`.

### Properties (what a mark can map)
- **Coordinate:** `x`, `y`, `xmin/xmax`, `ymin/ymax` — numeric, or categorical/temporal via scales.
- **Color:** `color`, `fillcolor`, `edgecolor` — Nominal → discrete hues; Continuous → gradient. Accept palette names (`"viridis"`, `"rocket"`, `"deep"`), parameterized (`"dark:blue"`, `"ch:start=.2,rot=-.4"`), interpolation tuples (continuous), lists/dicts (nominal), or single colors (`"#0F766E"`, `"C0"`, `"seagreen"`).
- **Alpha:** `alpha`, `fillalpha`, `edgealpha` — 0–1, Continuous.
- **Style:** `marker` (Nominal; codes like `'o'`,`'s'`,`'^'`), `linestyle`/`edgestyle` (`'-'`,`'--'`,`'-.'`,`':'` or `(on,off,...)`), `fill` (Boolean).
- **Size:** `pointsize` (sqrt scale, area-proportional), `linewidth`, `edgewidth`, `stroke` — all Continuous, point units.
- **Text:** `text` (literal), `halign`, `valign`, `fontsize`, `offset`.
- **group** — defines subsets for transforms; no visual effect.

### Scales
`so.Nominal` (discrete, unordered), `so.Continuous` (numeric, supports transforms/`trans="log"`), `so.Boolean`, `so.Temporal` (dates as days-from-epoch). Pass via `.scale(color=so.Continuous("mako"), x=so.Continuous(trans="log"), ...)`.
