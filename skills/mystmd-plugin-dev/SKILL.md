---
name: mystmd-plugin-dev
description: Use when writing a custom MyST (mystmd) `.mjs` plugin — a directive, role, or transform — for MyST sites (interactive figures, status banners, validation admonitions, metadata injection). Covers the plugin export shape, a directive's `run(data)` returning AST nodes, the raw-`html`-node-only constraint (inline `<script>` is sanitized → embed via iframe), registration via `project.plugins`, env-gating, and the MyST≤1.9 custom-frontmatter-from-disk workaround. Don't use for *using* existing directives (→ interactive-figures / myst-expert), site CI/deploy (→ myst-ci), or non-MyST plugin work.
---

# Authoring mystmd `.mjs` plugins

Write directives/roles/transforms that extend MyST sites. Worked examples: the interactive-figures
plugin (`../../mystmd-plugins/interactive.mjs`) and Anna's sophie plugins
(`~/Teaching/sophie/docs/website/scripts/*.mjs`).

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

## The hard constraints (learned the hard way)

- **Only the `html` node carries raw markup** (`{type:'html', value:'<...>'}`); there is no `iframe`/`raw`
  node type. And **inline `<script>` is sanitized out of the page** — so to run third-party JS, emit an
  **`<iframe srcdoc>`** (its own document/realm) rather than scripts in the page. (This is exactly how
  `interactive.mjs` embeds Plotly/Vega/Aladin.) If even `srcdoc` is stripped, write a standalone file and
  reference it.
- **Custom frontmatter is invisible to plugins in MyST ≤1.9** — custom keys aren't on
  `vfile.data.frontmatter`. To act on them (sophie's `status`/`validation`), **re-read the file from disk**
  in the transform. Pair with `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]` so MyST
  doesn't reject the keys.

## Patterns

- **Env-gating** optional output: `if (process.env.SOPHIE_DOCS_INCLUDE_VALIDATION === '0') return [];`
- **Deterministic placement** (e.g. inject after the H1): walk the tree in the `document`-stage transform.
- **Test** by running `myst start` on a fixture page; check the rendered DOM, not just the build exit code.

## Related
- Using shipped directives → `interactive-figures` / `myst-expert`. Deploy/CI → `myst-ci`.
