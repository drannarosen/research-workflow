---
name: myst-expert
description: Use when authoring, fixing, or deploying MyST (mystmd) content — colon-fence directives, roles, admonitions, cards/grids/tabs, figures, tables, KaTeX math, cross-references (`(label)=` + `[](#label)`), citations (`[@key]`), `myst.yml` and frontmatter, exports (PDF/LaTeX/Typst/DOCX), GitHub Actions deploy to Pages (working dir, BASE_URL for sub-path sites), and cross-project xref federation (`project.references`, `myst.xref.json`). Grounds you in the NEW mystmd, which differs from legacy Sphinx-MyST (no `conf.py`, Pandoc-style citations, cross-refs as Markdown links, KaTeX not MathJax). Don't use for a site's visual house style (the brain-local brain-frontend skill), Quarto (→ quarto-expert), prose voice (→ docs-writing-voice), or writing `.mjs` plugins and interactive-figure directives (→ mystmd-plugin-dev).
---

# MyST Expert (mystmd)

Author correct, current MyST for **mystmd** (mystmd.org) — not legacy Sphinx-MyST. This skill is the
syntax authority; for the brain's *visual* conventions (dashboards, badges) use `brain-frontend`.

## Reach for the references first

- `references/myst-cheatsheet.md` — directives, roles, admonitions/dropdowns, cards/grids/tabs,
  figures, tables, cross-references, citations, frontmatter — copy-paste examples.
- `references/math-and-gotchas.md` — KaTeX/LaTeX math (inline `$…$`, display `$$…$$`, labeled
  equations, macros) + the mystmd-vs-legacy gotchas.
- `references/ci-and-xref-patterns.md` — deploy workflows, node/mystmd pinning, BASE_URL, Pages gotchas, and the xref federation steps, distilled from the live repos.
- `references/myst-projects-and-workflows.md` — the **project/site** layer (`myst.yml`, authors/license/
  math-macros/abbreviations/numbering, exports, cross-project xref, binder/thebe executable content,
  custom `.mjs` plugins, CI) across Anna's five MyST workflows.

Both are source-backed from mystmd.org/guide (2026-06-06). When a directive's existence or exact
syntax is uncertain, check the reference or the live guide — don't guess.

## The load-bearing facts (what's actually different in mystmd)

- **Config is `myst.yml`.** No `conf.py`, no `_toc.yml`; the TOC lives under `project.toc`. Sphinx
  extensions and `myst_enable_extensions` are no-ops (math, deflists, GFM tables, footnotes are on by default).
- **Directives use colon fences** `:::{name} arg` with `:key: value` option lines; nest by adding
  fence characters (`::::`). Backticks are reserved for code-like content.
- **Cross-references are Markdown links.** Define a target with `(label)=` on the line above a heading;
  link with `[](#label)` (empty text auto-fills) or `@label`. `{ref}`/`{numref}`/`{eq}` are kept only
  for legacy compatibility.
- **Citations are Pandoc-style** `[@key]` / `@key` (multiple: `[@a; @b]`), with the `.bib` registered in
  `myst.yml`. No `sphinxcontrib-bibtex`.
- **Math is KaTeX, not MathJax.** `$…$`, `$$ … $$ (label)`, amsmath `align`/`gather`/`cases`; macros via
  the `math:` block in page frontmatter or `myst.yml`. MathJax-only macros fail silently.
- **Collapsible admonition** = any admonition + `:class: dropdown` (add `:open:` to start expanded) —
  distinct from the dedicated `{dropdown}` directive. There are ten fixed admonition types.
- **CLI:** `myst start` (serves localhost:3000), `myst build [--html|--pdf|--tex|--docx]`, `myst init`.

## Don't copy from old MyST / Sphinx

`{toctree}`, `{eval-rst}` / raw RST, autodoc & intersphinx, sphinxcontrib-bibtex setup, and arbitrary
Sphinx-extension directives are **unsupported** in core mystmd. (Theorem/proof directives are
theme/extension-dependent — verify before use.)

## Deploy and cross-project xref

Canonical GitHub Pages workflow: `actions/checkout` → `setup-node` (20 or 22) → `npm install -g mystmd` (pin a version for papers) → `myst build --html` in the site's working directory → `upload-pages-artifact` from that directory's `_build/html` → a separate `deploy` job with `environment: github-pages` and `actions/deploy-pages`. Permissions `{contents: read, pages: write, id-token: write}`.

- **Repo Settings → Pages → Source must be "GitHub Actions"**, not a branch — the most common silent failure.
- **Working directory and artifact path must match** (`docs/website/` → `docs/website/_build/html`).
- **Sub-path project sites need `BASE_URL`** (`/${{ github.event.repository.name }}/`) or assets 404.
- Custom frontmatter keys → `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]`; `--strict` as a clean-docs gate; notebooks execute only with `myst build --execute` and a science env on the runner.
- **Federation:** deploy the spoke → confirm `https://<site>/myst.xref.json` resolves → hub `myst.yml`: `project: {references: {stellax: https://<site>/}}` → link `[](xref:stellax#label)`. Keep `link-resolves` at `warn` while spokes come online. Current per-repo status is in the reference file; re-check it rather than trusting a snapshot.

## Related

- Visual house style / layout (dashboards, badges, math-rendering) → your site's own conventions; the
  brain uses a brain-local `brain-frontend` skill + `page-beautifier` agent.
- Prose voice → `docs-writing-voice`.
- `.mjs` plugins and the shipped interactive-figure directives → `mystmd-plugin-dev`.
