---
name: myst-expert
description: Use when authoring or fixing MyST (mystmd) markdown — brain pages or any mystmd site — and you need correct, current syntax: colon-fence directives (`:::{}`), inline roles, admonitions & dropdowns, cards/grids/tabs, figures, tables, KaTeX/LaTeX math, cross-references (`(label)=` + `[](#label)`), citations (`[@key]`), or `myst.yml`/frontmatter config. Grounds you in the NEW mystmd (mystmd.org), which differs from legacy Sphinx-MyST (no `conf.py`, Pandoc-style citations, cross-refs as Markdown links, KaTeX not MathJax). Spans all MyST research workflows — scientific manuscripts, software-package docs, executable/notebook sites (binder/thebe), ADR design docs, and federated hubs — including project/site config (`myst.yml`), frontmatter, exports (PDF/LaTeX/Typst/DOCX), and cross-project xref. Ships co-located cheatsheet, math/gotchas, and projects-&-workflows references. Don't use for a site's visual house-style/layout (the brain has its own brain-local `brain-frontend` skill), Quarto content (→ quarto-expert), or prose voice (→ docs-writing-voice / writing-science-voice / grant-writing-voice).
---

# MyST Expert (mystmd)

Author correct, current MyST for **mystmd** (mystmd.org) — not legacy Sphinx-MyST. This skill is the
syntax authority; for the brain's *visual* conventions (dashboards, badges) use `brain-frontend`.

## Reach for the references first

- `references/myst-cheatsheet.md` — directives, roles, admonitions/dropdowns, cards/grids/tabs,
  figures, tables, cross-references, citations, frontmatter — copy-paste examples.
- `references/math-and-gotchas.md` — KaTeX/LaTeX math (inline `$…$`, display `$$…$$`, labeled
  equations, macros) + the mystmd-vs-legacy gotchas.
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

## Hand-offs

- Visual house style / layout (dashboards, badges, math-rendering) → your site's own conventions; the
  brain uses a brain-local `brain-frontend` skill + `page-beautifier` agent.
- Prose voice → `docs-writing-voice`.
