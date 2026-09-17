---
name: mystmd-plugin-dev
description: Interactive figures and .mjs plugins for MyST sites (syntax → myst-expert). Use when adding interactive figures to a MyST (mystmd) site or writing a custom `.mjs` plugin — using the shipped `{plotly}`, `{vega-lite}`, and `{aladin}` directives (static embeds, no kernel) or live thebe/Jupyter cells, and authoring directives, roles, or transforms (plugin export shape, `run(data)` returning AST nodes, registration via `project.plugins`). Covers the load-bearing constraints: inline `<script>` is sanitized so widgets embed via `<iframe srcdoc>`, embeds don't survive PDF/Word export, and custom frontmatter is invisible to plugins in MyST ≤1.9. Don't use for general mystmd syntax, deploy, or xref (→ myst-expert), or static publication figures (→ astro-plotting-craft / figure-review).
---

# Authoring mystmd `.mjs` plugins

Use the shipped interactive-figure directives, or write your own directives/roles/transforms. Worked
example: `../../mystmd-plugins/interactive.mjs`. Implementation research and caveats:
[references/mystmd-interactive-research.md](references/mystmd-interactive-research.md).

## Using the shipped interactive directives

Register the plugin (`project: {plugins: [path/to/interactive.mjs]}`), then:

````md
```{plotly}
{"data":[{"x":[1,2,3],"y":[2,5,3],"type":"scatter"}]}
```

```{aladin}
:target: M51
:fov: 0.5
```
````

- Paste `fig.to_json()` (Plotly) or an Altair/Vega-Lite spec into the body.
- **Static (no kernel):** Plotly, Vega-Lite, Aladin work on plain GitHub Pages. Plotly/Altair outputs from a `{code-cell}` already embed without a directive; Mermaid is native.
- **Live compute:** `project.jupyter: true` plus thebe/binder (needs a kernel).
- **Not in PDF/Word** — give a static image fallback for exports.
- **De-risk first:** confirm a `{mermaid}` block, a notebook Plotly output, and a bare `<iframe>` render in the *deployed* theme. If `<iframe srcdoc>` is stripped, write each widget to `_static/viz/<name>.html` and embed with `{iframe}`.

## Plugin shape

```js
export default {
  name: 'My plugin',
  directives: [ /* directive objects */ ],
  roles:      [ /* inline roles */ ],
  transforms: [ /* AST transforms, e.g. {stage:'document', plugin(){...}} */ ],
};
```

Register in the site's `myst.yml`:
```yaml
project:
  plugins: [scripts/my-plugin.mjs]
```

## A directive

```js
const myDir = {
  name: 'callout',
  doc: 'One-line description (shows in tooling).',
  arg:     { type: String },                       // the `:::{callout} ARG`
  options: { color: { type: String } },            // :color: ...
  body:    { type: String },                       // the fenced body
  run(data) {                                       // data.arg / data.options / data.body
    return [{ type: 'admonition', children: [ /* AST nodes */ ] }];
  },
};
```

`run()` returns an **array of AST nodes**. Verify the option/arg/body schema and node types against your
installed mystmd version — the API surface evolves.

## Constraints

- **Only the `html` node carries raw markup** (`{type:'html', value:'<...>'}`); there is no `iframe`/`raw`
  node type. And **inline `<script>` is sanitized out of the page** — so to run third-party JS, emit an
  **`<iframe srcdoc>`** (its own document/realm) rather than scripts in the page. (This is exactly how
  `interactive.mjs` embeds Plotly/Vega/Aladin.) If even `srcdoc` is stripped, write a standalone file and
  reference it.
- **Custom frontmatter is invisible to plugins in MyST ≤1.9** — custom keys aren't on
  `vfile.data.frontmatter`. To act on them (e.g. a custom `status` or `validation` key), **re-read the file from disk**
  in the transform. Pair with `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]` so MyST
  doesn't reject the keys.

## Patterns

- **Env-gating** optional output: `if (process.env.DOCS_INCLUDE_VALIDATION === '0') return [];`
- **Deterministic placement** (e.g. inject after the H1): walk the tree in the `document`-stage transform.
- **Test** by running `myst start` on a fixture page; check the rendered DOM, not just the build exit code.

## Related
- General mystmd syntax, deploy/CI, and xref → `myst-expert`.
- Static publication figures → `astro-plotting-craft` / `figure-review`.
