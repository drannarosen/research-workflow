---
title: "MyST projects & workflows — versatile reference"
type: reference
status: source-backed
updated: 2026-09-16
---
(myst-projects-and-workflows)=
# MyST projects & workflows

How to set up a MyST (mystmd) **project** for each common research-documentation workflow. Syntax-level detail is in
[myst-cheatsheet.md](myst-cheatsheet.md) and [math-and-gotchas.md](math-and-gotchas.md); this page is
the **project/site** layer (`myst.yml`, frontmatter, exports, xref, CI). Patterns below are drawn from
working configs for paper sites, package docs, course sites, design docs, and a knowledge hub — ground truth:
<https://mystmd.org/guide/frontmatter> and the guide's configuration pages.

## The five workflow archetypes

| Workflow | Typical location | What it needs |
|---|---|---|
| **Manuscript companion (paper site)** | `<paper-repo>/docs` | `authors` (ORCID/affiliations/corresponding), `bibliography`, `abbreviations`, dual `license`, `open_access`, article-style structure |
| **Package docs** | `<repo>/docs/website` | math macros, deep API/theory toc, validation + dated dev-log sections, "single source of truth" framing |
| **Course site** | repo root | `binder:` + `thebe:` for live code, heavy `exclude:` globs, analytics, PDF export off |
| **Design / ADR docs** | `<repo>/docs/website` | custom frontmatter (`status`, `validation`), `error_rules` to silence it, custom `.mjs` plugins, slug-collision overrides |
| **Federated knowledge hub** | hub repo root | custom metadata keys, optional post-build aggregation script, cross-project `xref`, `link-resolves: warn` |

All use `site.template: book-theme`. Use `article-theme` for a single manuscript.

## `myst.yml` skeleton (project config)

```yaml
version: 1
project:
  id: <uuid-or-slug>
  title: <string>
  description: <string>
  authors:
    - name: Your Name
      orcid: 0000-0000-0000-0000  # your ORCID
      affiliations: [my-institution]
      email: you@example.edu
      corresponding: true
  affiliations:
    - id: my-institution
      name: Your Institution
  license:
    code: BSD-3-Clause
    content: CC-BY-4.0
  github: https://github.com/<org>/<repo>
  keywords: [...]
  bibliography: [references.bib]
  abbreviations:                  # auto-expanded on hover in prose
    IMF: initial mass function
    DAPR: dual-anonymous peer review
  math:                           # project-wide macros (see math-and-gotchas.md)
    '\Msun': '\mathrm{M}_\odot'
    '\Rsun': '\mathrm{R}_\odot'
  numbering:
    headings: false
    figure: {enabled: true}
    equation: {enabled: true}
    table: {enabled: true}
  toc:
    - file: index.md
    - title: <Section>
      children: [ {file: ...}, ... ]
site:
  template: book-theme
  options:
    logo_text: <name>
    analytics: {google: <GA-id>}
    github_url: https://github.com/<org>/<repo>
    comments: {utterances: {repo: <org/repo>, issue_term: pathname}}
```

## Custom frontmatter (the MyST 1.9 gotcha)

Design docs and knowledge hubs often carry non-standard page keys (e.g. `status`, `type`, `hat`,
`confidence`, `validation`). MyST's schema rejects unknown keys, so silence it and validate at the app layer:

```yaml
  error_rules:
    - rule: valid-page-frontmatter
      severity: ignore
```

**Plugin caveat:** in MyST ≤1.9 custom keys are **not** exposed via `vfile.data.frontmatter` — a
`.mjs` plugin must re-read the file from disk to see them (e.g. a validation-admonition or
spec-status-banner plugin).

## Cross-project references (xref / federation)

`references` must be **URLs of deployed MyST sites**, each exposing `myst.xref.json`:

```yaml
project:
  references:
    pkg-a: https://<org>.github.io/<repo>/
```

Then deep-link with `xref:pkg-a/<label>` or `[](xref:pkg-a#label)`. Referenced sites must be
**published** first. Tolerate not-yet-live links with `error_rules: [{rule: link-resolves, severity: warn}]`.

## Executable content (course sites)

```yaml
project:
  binder: https://mybinder.org/v2/gh/<org>/<repo>/main
  thebe:
    binder: {repo: <org>/<repo>, ref: main}
    kernelName: python3
```

Make a code block runnable with ```` ```{code-cell} python ````. Exclude drafts/notebooks/data with
`project.exclude: [draft*, "**/*.ipynb", "**/__pycache__/**", ...]`.

## Custom `.mjs` plugins

Load AST-transform plugins from a scripts dir; they run at `stage: document`:

```yaml
project:
  plugins:
    - scripts/validation-admonition-plugin.mjs
```

Gate optional output behind env vars (e.g. `DOCS_INCLUDE_VALIDATION=0`). Node/ESM modules —
this is where Node/TS is the right tool (see `mystmd-plugin-dev`).

## Exports (PDF / LaTeX / Typst / DOCX)

Many research sites are **web-first and configure no `exports:`** (course sites often switch PDF
export off). When a paper needs a PDF/LaTeX build, add per-document or project-level:

```yaml
exports:
  - format: pdf      # or tex, typst, docx
    template: <template-name>
    output: exports/paper.pdf
```

Build with `myst build --pdf` (needs a LaTeX/Typst toolchain). For documents with strict external
formatting (e.g. grant proposals), authoring in Typst or LaTeX directly can be simpler than MyST export.

## Build / CI

- Local: `myst start` (localhost:3000) · `myst build --html`.
- CI (GitHub Actions): `npm install -g mystmd[@<ver>]` then `myst build --html`; deploy
  `_build/html`. Working dir is `docs/` or `docs/website/` depending on the project; pin the version
  for papers (e.g. `mystmd@1.8.3`), latest for package docs. Full recipes: `ci-and-xref-patterns.md`.

## Recurring content structure (package docs / papers)

`Getting started → Theory/Architecture → API → How-to → Validation → Development log → Bibliography`.
Validation checklists and **dated** dev-log / verification-log entries are first-class toc sections.

## File naming & section ordering (package docs)

Two schemes work well (numeric prefixes or semantic section names):

- **Numeric section prefixes** order the toc deterministically: `00-getting-started/`, `10-theory/`,
  `30-api/`, … `99-bibliography/`. The alternative is semantic section dirs
  (`engineering/`, `validation/`, `analysis-viz/`). Pick one scheme per project and stay consistent.
- **Markdown files** are `lowercase-with-hyphens.md` (`ic-philosophy.md`, `spatial-profiles.md`).
- Each major section has an `index.md` landing page; the toc is **explicit** in `myst.yml`
  (`project.toc`), never auto-discovery.
- **API pages are auto-generated by an _idempotent_ script** (`scripts/build_api_reference.py`):
  re-running it produces no diff. NumPy-style docstrings, one page per public module, GitHub source
  links, an alphabetical symbol index. (A hand-maintained module inventory also works — both are
  fine; don't mix autodoc directives in, they're unsupported — see myst-expert.)

## Validation page pattern (package docs)

The signature of good research package docs: every quantitative claim is *checkable*. A validation page is a
`{list-table}` mapping each property → the tolerance it must meet → the measured value → the **anchor**
(the test, or the physical identity, that enforces it). This is the docs-layer of the evidence-first
stance — pair it with `research-workflow`'s `reference-parity-audit` / `provenance`.

````markdown
```{list-table}
:header-rows: 1

* - Property
  - Tolerance
  - Measured
  - Anchor
* - Half-mass radius
  - 1e-6 rel
  - 0.7664
  - `tests/validation/test_plummer_physics.py::test_half_mass_radius`
```
````

- Put the **test file path** (ideally `path::test_name`) in the Anchor column so a reader can run it.
- Embed figures from the validation script (PNG for the web build; the same script emits the paper PDF).
- Record cutover/verification events as **dated** (`YYYY-MM-DD`) dev-log entries that link the PR/issue.
- Caption figures with the key result and its metric ("max rel error = 1.2%"), not just a description.
