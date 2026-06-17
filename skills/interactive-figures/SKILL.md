---
name: interactive-figures
description: Use when adding interactive figures/charts to a MyST (mystmd) site — Plotly, Vega-Lite, interactive sky maps (Aladin Lite), or live Jupyter/thebe cells — via the shipped `.mjs` directives (`{plotly}`, `{vega-lite}`, `{aladin}`) or native notebook outputs. Covers static-deploy embeds (no kernel) vs live compute, and the MyST sanitizer/iframe constraint. Don't use for static publication figures (→ the plot-* skills: plot-design-inspector / publication-figure-validator), general mystmd syntax (→ myst-expert), or writing new `.mjs` directives from scratch (→ mystmd-plugin-dev).
---

# Interactive figures in MyST

Add interactive viz to mystmd sites. Implementation research + caveats:
[references/mystmd-interactive-research.md](references/mystmd-interactive-research.md). The directives
ship at `../../mystmd-plugins/interactive.mjs`.

## The one fact that shapes everything

**MyST sanitizes inline `<script>` in the page**, so a raw `html` node with a `<script>` won't run.
Interactive widgets are therefore embedded in an **`<iframe srcdoc>`** (own realm; also dodges
SSR/hydration). These render in the **static HTML build** (no kernel) but **not in PDF/Word** exports —
supply a static `:poster:`/image fallback for those.

## Load the plugin

```yaml
# site myst.yml
project:
  plugins:
    - path/to/interactive.mjs   # copy ../../mystmd-plugins/interactive.mjs into the site, or reference it
```

## Use it

````md
```{plotly}
{"data":[{"x":[1,2,3],"y":[2,5,3],"type":"scatter"}],"layout":{"title":"Demo"}}
```

```{vega-lite}
{"data":{"values":[{"a":"A","b":28},{"a":"B","b":55}]},"mark":"bar",
 "encoding":{"x":{"field":"a"},"y":{"field":"b","type":"quantitative"}}}
```

```{aladin}
:target: M51
:fov: 0.5
```
````

For Python figures, paste `fig.to_json()` (Plotly) or the Altair/Vega-Lite spec into the body.

## Static vs live

- **Static (no kernel):** Plotly, Vega-Lite, Aladin — self-contained, work on plain GitHub Pages.
- **Native notebook outputs:** Plotly/Altair rendered in a `{code-cell}` already embed without a directive.
- **Live compute:** set `project.jupyter: true` + thebe/binder for runnable cells (needs a kernel).
- **Mermaid** is first-class/native (diagrams) — no plugin needed.

## De-risk before trusting it (do this first)

The `.mjs` is a **starter** — validate against your mystmd version: confirm (1) a `{mermaid}` block, (2)
a notebook Plotly output, and (3) a bare `<iframe>` all render in the *deployed* book theme. If
`<iframe srcdoc>` is stripped by the sanitizer, switch to the **standalone-page fallback**: write each
widget to `_static/viz/<name>.html` and embed with a plain `{iframe}` pointing at that URL.

## Hand-offs
- Authoring/extending the `.mjs` directives → `mystmd-plugin-dev`.
- General mystmd syntax → `myst-expert`. Static publication-quality figures → `plot-design-inspector` / `publication-figure-validator`.
