---
title: Interactive figures in mystmd — implementation reference
type: reference
status: source-backed
updated: 2026-06-06
---

(myst-interactive-research)=

# Interactive figures in mystmd — implementation reference

Research basis: the live mystmd docs (`mystmd.org/guide`) and the official Aladin
Lite / sanitize-html docs, fetched 2026-06-06. Provenance label per claim below.
Items I could not confirm verbatim from a primary source are marked **(verify)**.

## Ground-truth URLs

- Plugins overview — <https://mystmd.org/guide/plugins>
- JavaScript (`.mjs`) plugins — <https://mystmd.org/guide/javascript-plugins>
- Executable (any-language) plugins — <https://mystmd.org/guide/executable-plugins>
- MyST AST schema (node types incl. `html`) — <https://mystmd.org/spec/myst-schema>
- Rich notebook outputs / interactive figures — <https://mystmd.org/guide/interactive-notebooks>
- In-page execution (thebe + Binder) — <https://mystmd.org/guide/in-page-execution>
- Launch buttons — <https://mystmd.org/guide/website-launch-buttons>
- Mermaid diagrams (native) — <https://mystmd.org/guide/diagrams>
- Images / figures / videos / `{iframe}` — <https://mystmd.org/guide/figures>
- Thebe options — <https://mystmd.org/thebe/options>
- Aladin Lite v3 API — <https://cds-astro.github.io/aladin-lite/> and
  <https://aladin.cds.unistra.fr/AladinLite/doc/API/>
- JS9 (in-browser FITS) — <https://js9.si.edu/>
- sanitize-html (the XSS model that explains script stripping) —
  <https://www.npmjs.com/package/sanitize-html>

---

## 1. The mystmd plugin / directive API (`.mjs`)

`source-backed` — <https://mystmd.org/guide/plugins>, <https://mystmd.org/guide/javascript-plugins>

MyST supports three plugin extension points: **directives** (block-level),
**roles** (inline), and **transforms** (mutate the AST during the build). JavaScript
`.mjs` plugins are described by the docs as "the easiest way to write and share
plugins."

### Directive object shape

A directive is a plain object. Fields (from the canonical `picsum` example in the
docs):

```javascript
const picsumDirective = {
  name: 'picsum',
  doc: 'An example directive ...',
  alias: ['random-pic'],
  arg: {                              // the inline argument after the directive name
    type: String,
    doc: 'The ID of the image to use, e.g. 1',
  },
  options: {                          // ::: option: value
    size: { type: String, doc: 'Size of the image, e.g. 500x200.' },
  },
  body: { type: String, doc: '...' },  // optional; the fenced body content
  run(data) {
    // data.arg      -> the argument string
    // data.options  -> { size: '500x200', ... }
    // data.body     -> the body string (when body is declared)
    const img = { type: 'image', url: '...' };
    return [img];                     // MUST return an array of AST nodes
  },
};
```

`run(data)` returns an **array of MyST AST nodes**. Confirmed fields on `data`:
`arg`, `options`, `body` (docs reference `data.options?.size`). Common node types
the docs build: `image`, `heading`, `paragraph`, `text`, `span`, `strong`,
`emphasis`. **(verify)** whether `data` also carries the raw parsed `node`/`vfile`
— the docs show only `arg`/`options`/`body` in worked examples.

### Emitting raw HTML — the `html` node

`source-backed` — <https://mystmd.org/spec/myst-schema>

The AST schema **does include an `html` node**: "Fragment of raw HTML — does not
need to be valid or complete," with a required `value` (string). This is the
mechanism to inject arbitrary markup (e.g. a target `<div>` for a JS widget):

```javascript
run(data) {
  return [{ type: 'html', value: `<div id="myviz-${Date.now()}"></div>` }];
}
```

There is **no** dedicated `iframe` or `raw` AST node — the generic `html` node is
the path for iframes/raw constructs. ⚠️ See §5: `html` node content is **sanitized**
in the renderer, so inline `<script>` will not survive. The `image` node is the
clean path when the widget can be reduced to an image; the `{iframe}` *directive*
(not an AST node — it expands to image/embed structure) is the clean path for
arbitrary JS.

### Plugin export + registration

`source-backed` — both pages

```javascript
const plugin = { name: 'Lorem Picsum Images', directives: [picsumDirective] };
export default plugin;          // { name, directives?, roles?, transforms? }
```

```yaml
# myst.yml
version: 1
project:
  plugins:
    - local/folder/picsum.mjs                       # local path
    - https://github.com/org/repo/releases/.../x.mjs # or remote URL
```

### Transforms (for post-processing / script injection at build)

`source-backed` — <https://mystmd.org/guide/javascript-plugins>

```javascript
{
  name: 'transform-typography',
  stage: 'document',                       // when it runs
  plugin: (_, utils) => (node) => {
    utils.selectAll('strong', node).forEach((n) => { /* mutate */ });
  },
}
```
`plugin: (config, utils) => (tree) => {}`. `utils.selectAll(type, tree)` is the
documented AST query helper (unist-style). Useful for: walking the tree to collect
which widget types are present and (potentially) appending a loader.

### Executable (any-language) plugins

`source-backed` — <https://mystmd.org/guide/executable-plugins>

For Python etc.: the plugin is an executable that reads the AST as JSON on STDIN,
mutates it, writes JSON to STDOUT. It declares a `PLUGIN_SPEC` (same shape as the JS
object) **minus** the `run` body. Heavier to wire up than `.mjs`; **not recommended**
for the figure directives here — `.mjs` is strictly simpler and runs in-process.

---

## 2. Native / first-class interactive support

### Mermaid — native

`source-backed` — <https://mystmd.org/guide/diagrams>. A ```` ```mermaid ```` code
block (or `{mermaid}` directive) renders natively, same as GitHub/JupyterLab. No
plugin needed. This is the one truly first-class interactive-ish diagram type.

### Jupyter notebook outputs — native, rendered as-is

`source-backed` — <https://mystmd.org/guide/interactive-notebooks>. If you drop
`*.ipynb` into the project, MyST parses them and "shows the full results … including
any interactive figures." Outputs render from their mime bundles. Crucial
qualifier (paraphrased from the same guide): interactive outputs render in the
**static** site **only when the output is self-contained HTML that needs no external
runtime** — i.e. Altair/Vega-Lite and Plotly's HTML export embed their own JS and
work; **ipywidgets do not** (they need a live kernel/comm). Treat "notebook output"
and "live widget" as two different things.

### Live interactivity — thebe + Binder/JupyterLite (NOT static)

`source-backed` — <https://mystmd.org/guide/in-page-execution>,
<https://mystmd.org/guide/website-launch-buttons>, <https://mystmd.org/thebe/options>

```yaml
project:
  jupyter: true                 # simplest: enable in-page execution via thebe
# or, pin the environment:
project:
  jupyter:
    binder:
      repo: https://github.com/jupyter-book/thebe-binder-base  # or owner/repo
      ref: main                 # optional branch/tag/commit
      url: https://mybinder.org # optional custom BinderHub
      provider: github          # optional
```
Reader clicks a "power" button → a Binder kernel spins up → `{code-cell}`s become
executable; a "Launch" button can open JupyterHub/BinderHub. **This requires a
running kernel** — it is the right tool for *live* widgets (ipywidgets, bokeh
server), but it is **not** a static-build solution and depends on a third-party
compute service (mybinder.org cold starts, downtime). Out of scope for "static,
no kernel," but worth offering as an opt-in layer.

---

## 3. Client-side libraries that work in a STATIC build (no kernel)

All three below are pure client JS over a JSON spec → ideal for a directive that
takes a spec body or a `:file:` path. The static-render constraint from §2 is the
guiding principle: **the embedded payload must bring its own JS**.

| Library | Static-OK? | Spec source | Embedding strategy |
|---|---|---|---|
| **Vega-Lite / Vega** | yes (self-contained) | JSON spec (body or file) | div + vega-embed |
| **Plotly** | yes (`fig.to_json()` or HTML export) | JSON (`data`+`layout`) | div + Plotly.newPlot |
| **Observable Plot** | yes | JS expression returning a mark | div + Plot.plot |

### The sanitization wrinkle (decides the design)

The MyST renderer sanitizes raw HTML (sanitize-html / rehype-sanitize family), so a
directive that returns an `html` node containing `<script>…Plotly.newPlot…</script>`
**will have the script stripped** and the chart will not render. `source-backed`
on the *mechanism* (sanitizers strip top-level `<script>`; srcdoc bypasses it) —
<https://www.npmjs.com/package/sanitize-html>; **(verify)** the exact allow-list
MyST ships, but assume scripts are removed.

Two viable designs follow from this:

**Design A — `{iframe}`-with-`srcdoc` (most robust, recommended).** The directive
emits an `html` node whose value is a single `<iframe srcdoc="…">` containing a
complete mini-HTML doc (CDN `<script src>` for the lib + a `<script>` that renders
into a div from the inlined JSON). Scripts inside an iframe's `srcdoc` execute even
when top-level scripts are stripped (this is the documented sanitizer-bypass
behavior — here we use it intentionally and safely with our own content).
**(verify)** that MyST's sanitizer permits the `<iframe srcdoc>` attribute through —
if it strips `srcdoc`, fall back to Design B.

**Design B — external self-contained HTML page + `{iframe}` directive by URL.** A
build step writes `_static/viz/<hash>.html` (full standalone page) and the directive
emits `{iframe}` pointing at that URL. This sidesteps sanitization entirely (it is
just an `src`), is the most predictable, and is exactly how the docs already embed
YouTube/Vimeo via `{iframe}`. Cost: a companion file per figure.

**Plotly specifics:** in Python, `fig.to_json()` gives `{data, layout}`; render with
`Plotly.newPlot(div, data, layout)` after loading `plotly-latest.min.js` from CDN.
Alternatively `fig.write_html(..., include_plotlyjs='cdn', full_html=True)` produces
a ready standalone page → drop straight into Design B with zero JS authoring.

**Vega-Lite specifics:** load `vega`, `vega-lite`, `vega-embed` from CDN, then
`vegaEmbed('#id', spec)`. Spec is the JSON the directive body carries.

**Observable Plot specifics:** load `@observablehq/plot` (+ d3) from CDN; body is a
JS snippet returning a mark; render with `div.append(Plot.plot({...}))`. Slightly
more awkward as a directive because the body is code, not declarative JSON — lower
priority than Vega-Lite/Plotly.

---

## 4. Astronomy-specific embeds

### Aladin Lite (interactive sky atlas)

`source-backed` — <https://cds-astro.github.io/aladin-lite/>,
<https://aladin.cds.unistra.fr/AladinLite/doc/API/>

v3 embed pattern: a `<div>` target, the CDN script
`https://aladin.cds.unistra.fr/AladinLite/api/v3/latest/aladin.js`, then
`A.init.then(() => { A.aladin('#div', {target, fov, projection, …}); })`
(`A.init` must resolve — it checks WebGL2 — before `A.aladin`). This is **exactly**
the Design-A/B pattern: a div + a script that calls a global. Because the script
must run, embed via `{iframe srcdoc}` (Design A) or a standalone page + `{iframe}`
URL (Design B). A `{aladin}` directive maps options (`target`, `fov`, `survey`/HiPS,
`projection`) → the `A.aladin(...)` config. **Caveat:** WebGL2 required; the iframe
needs explicit width/height (Aladin sizes to its container).

### JS9 (in-browser FITS viewer)

`source-backed` — <https://js9.si.edu/>. JS9 ships its own JS + CSS and a
`<div class="JS9">` target, then `JS9.Load("file.fits", {...})`. It has more moving
parts than Aladin (CSS, optional helper, web-worker for some ops) and a heavier
setup. **Strongly prefer Design B (standalone page + `{iframe}` URL)** so JS9's own
asset loading is isolated from the book theme. Mark JS9 as **higher effort /
higher risk** than Aladin. **(verify)** current JS9 CDN/asset URLs before shipping.

Both are also embeddable as a bare `{iframe}` to an externally hosted instance
(e.g. a CDS Aladin URL) with **zero plugin work** — a good first milestone.

---

## 5. Hydration / SSR caveats in the book theme

`source-backed` (mechanism) / **(verify)** (exact MyST allow-list)

1. **Raw `<script>` in `html` nodes is stripped by the renderer's sanitizer.** Do
   not rely on inline scripts returned from a directive. (sanitize-html model.)
2. **SSR + hydration:** the book theme is a React/SSR app; third-party widgets that
   poke the DOM directly can clash with hydration. Isolating each widget in an
   `<iframe>` (its own document/realm) is the safest pattern and sidesteps both the
   sanitizer and hydration timing. This is why §3 lands on iframe-based designs.
3. **Global script loading is not first-class.** There is no documented per-page
   `<head>` script include for arbitrary JS. A transform (§1) could in principle
   append a loader node, but the sanitizer still applies — so iframes remain the
   robust route. **(verify)** whether current MyST exposes a project-level
   `html_head`/extra-JS hook; if it does, that becomes an alternative to per-iframe
   CDN includes.
4. **iframe sizing:** widgets sized to container need explicit width/height on the
   iframe; expose both as directive options. Add `loading="lazy"` for heavy embeds.
5. **Offline/PDF/Word exports:** iframe widgets won't render in static exports —
   provide a static `image` fallback (e.g. a poster PNG option on each directive).

---

## Recommended directive set + plan

Ship a single `.mjs` plugin (e.g. `interactive-figures.mjs`) exporting these
directives, in priority order:

1. **`{plotly}`** — body or `:file:` = Plotly JSON (`fig.to_json()`); render via
   iframe-srcdoc + CDN plotly.js. Highest value for science notebooks.
   *Effort: low. Risk: low.* Fallback: notebook `{code-cell}` output already works.
2. **`{vega-lite}`** (alias `{vegalite}`) — body/`:file:` = Vega-Lite JSON; iframe +
   vega-embed CDN. *Effort: low. Risk: low.*
3. **`{aladin}`** — options `target`, `fov`, `survey`, `projection`; iframe + Aladin
   v3 CDN. *Effort: low-med. Risk: med (WebGL2, sizing).* Big payoff for astro.
4. **`{js9}`** — `:file:` = FITS URL; standalone-page (Design B) embed.
   *Effort: med-high. Risk: med-high (heavier assets).* Ship last / optional.
5. *(optional)* **`{observable-plot}`** — body = JS mark; iframe. *Effort: med
   (code-as-body). Risk: low.* Lower priority than declarative specs.

**Embedding strategy (default for all):** **Design A — `{iframe srcdoc}`** for a
zero-extra-files dev experience, with **Design B** (build a standalone
`_static/viz/*.html` + `{iframe}` URL) as the fallback if MyST's sanitizer strips
`srcdoc`. Every directive should accept a `:poster:` / `:alt:` static-image option
for non-HTML exports.

**First milestone (de-risk in an hour):** prove the pipeline with the **native**
paths before writing any plugin — a `{mermaid}` block, a Plotly/Altair
**notebook output**, and a bare `{iframe}` to a hosted Aladin URL. If those render
in your deployed book theme, the directive layer is purely ergonomics on top.

### Top feasibility caveats (read before building)

- **Sanitizer strips inline `<script>`** → you cannot just return an `html` node
  with a script. Everything routes through iframes. **(verify)** that `<iframe
  srcdoc>` survives MyST's sanitizer; if not, use Design B exclusively.
- **ipywidgets / bokeh-server are NOT static** — they need thebe+Binder (§2).
  Don't promise live widgets without a kernel.
- **Plotly/Altair from notebooks already render** — for notebook-driven figures you
  may not need a directive at all; the directives matter for spec/file-driven and
  astro embeds.
- **JS9 and Aladin need WebGL2 / heavier assets** and won't appear in PDF/Word
  exports — always provide a static fallback image.
- **Live execution depends on mybinder.org** (cold starts, outages) — fine as an
  opt-in, not as the core static experience.
