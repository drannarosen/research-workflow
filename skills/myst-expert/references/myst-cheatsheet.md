---
title: MyST (mystmd) Cheatsheet
type: reference
status: source-backed
updated: 2026-06-06
---

(myst-cheatsheet)=

# MyST (mystmd) Cheatsheet

> Ground truth: **new mystmd** at <https://mystmd.org/guide> (NOT legacy Sphinx-MyST / myst-parser).
> Key pages: [syntax-overview](https://mystmd.org/guide/syntax-overview) · [typography](https://mystmd.org/guide/typography) · [admonitions](https://mystmd.org/guide/admonitions) · [dropdowns-cards-and-tabs](https://mystmd.org/guide/dropdowns-cards-and-tabs) · [figures](https://mystmd.org/guide/figures) · [tables](https://mystmd.org/guide/tables) · [code](https://mystmd.org/guide/code) · [cross-references](https://mystmd.org/guide/cross-references) · [external-references](https://mystmd.org/guide/external-references) · [citations](https://mystmd.org/guide/citations) · [frontmatter](https://mystmd.org/guide/frontmatter) · [directives](https://mystmd.org/guide/directives)
>
> Examples below are copy-paste-ready. Items I could not fully verify are marked **(verify)**.

---

## Directive & role syntax (the foundation)

A **directive** is a multi-line block. Prefer the **colon fence** for Markdown content; use the **backtick fence** for code-like content (math, mermaid, code).

```text
:::{directivename} positional-argument
:key1: value1
:key2: value2

Body content (Markdown).
:::
```

Backtick fence (equivalent; required for executable `{code-cell}` in notebooks):

````text
```{math}
:label: my-eq
e = mc^2
```
````

**Nesting** — give the OUTER directive more fence chars than the inner one (`::::` wraps `:::`, or `````` wraps ````):

```text
::::{note} Outer
:::{tip} Inner
Nested!
:::
::::
```

**Option formats** (interchangeable): `:key: value` lines, a YAML `---` block, or **inline options** `{name .class #label key="value"}`.

A **role** is inline (single line):

```text
Press {kbd}`Ctrl` + {kbd}`C` to copy water, H{sub}`2`O.
```

Inline role options: `` {span #id .my-class}`text` ``. Unknown roles/directives parse but render plainly.

---

## Typography & formatting

```text
**bold**   _italic_   `inline code`
{del}`strikethrough`   {u}`underline`   {sc}`small caps`

H{sub}`2`O          4{sup}`th`
{abbr}`MyST (Markedly Structured Text)`
{kbd}`Ctrl` + {kbd}`Space`

# H1 ... ###### H6

Line break with trailing backslash: \
next line.
```

Blockquote / definition list / footnotes / task list:

```text
> Quote text
> — Attribution

Term
: Definition for the term

- [x] done
- [ ] todo

Here is a footnote[^1].

[^1]: The footnote text.
```

Lists:

```text
- bullet
  - nested
1. ordered
2. ordered
```

---

## Admonitions

Ten named types — same colon-fence form. The single argument is the **title** (Markdown allowed; optional, defaults to the type name):

```text
:::{note}
A note.
:::

:::{warning} Custom Title
Body.
:::
```

Names: `note` · `tip` · `important` · `hint` · `seealso` · `attention` · `caution` · `warning` · `danger` · `error`.

Generic admonition with explicit styling class (Sphinx/Jupyter-Book-v1 compatible):

```text
:::{admonition} The Title
:class: hint
Body styled as a hint.
:::
```

**Collapsible** — add `:class: dropdown` to ANY admonition; `:open:` starts it expanded:

```text
:::{note} Click to expand
:class: dropdown
:open:
Hidden until clicked (but starts open here).
:::
```

Other options: `:icon: false` (hide icon), `:class: simple` (lighter style). Inline form: `` :::{warning .simple .dropdown icon=false} ``.

---

## Dropdowns, cards, grids, tabs

**Dropdown** (dedicated directive; simpler than a dropdown-admonition):

```text
:::{dropdown} Dropdown Title
:open:
Content shown when expanded.
:::
```

**Card** — argument is the title; `^^^` separates header, `+++` separates footer; `:link:` (alias `:url:`) makes the whole card clickable:

```text
:::{card} Card Title
:link: https://mystmd.org

Card body.
:::
```

```text
:::{card} Title
Header text
^^^
Body content
+++
Footer text
:::
```

**Grid** — the argument is column counts at 4 breakpoints `xs sm md lg` (`<768 / 768–1024 / 1024–1280 / >1280`px). Use `::::` since it wraps inner cards/items. Per-item span via `:columns:` (1–12):

```text
::::{grid} 1 1 2 3
:::{card} One
First card.
:::
:::{card} Two
Second card.
:::
:::{grid-item}
:columns: 6
A raw grid item spanning 6 columns.
:::
::::
```

(`grid-item-card` exists as a Sphinx-design alias; in mystmd prefer a `{card}` directly inside `{grid}`.)

**Tabs** — `{tab-set}` wraps `{tab-item}` (argument = tab label). `:sync:` links tabs with the same key across the page:

```text
::::{tab-set}
:::{tab-item} Python
:sync: py
```python
print("hi")
```
:::
:::{tab-item} Julia
:sync: jl
```julia
println("hi")
```
:::
::::
```

**Buttons** are a **role**, not a directive — `` {button}`Text <target>` ``:

```text
{button}`MyST Docs <https://mystmd.org>`
{button}`Internal link <#my-label>`
{button}`A button without a link!`
```

---

## Figures & images

Simple image: `![alt text](path/to/img.png "optional title")`

```text
:::{image} ./img.png
:alt: Alternative text
:width: 400px
:align: center
:::
```

**Figure** (caption = the body; `:label:` enables cross-refs and numbering):

```text
:::{figure} ./img.png
:label: fig-demo
:alt: Description
:width: 80%
:align: center

This caption supports **Markdown** and is numbered automatically.
:::
```

Subfigures — nest `![]()` images inside a `{figure}` with no argument:

```text
:::{figure}
:label: fig-pair

![left](a.png)
![right](b.png)

A combined caption.
:::
```

Video: `:::{figure} ./clip.mp4` or just `![](./clip.mp4)`. Embeds: `{iframe}` with `:width:`/`:title:`.

---

## Tables

Pipe (GFM) table; colons set alignment:

```text
| Left | Center | Right |
| :--- | :----: | ----: |
| a    | b      | c     |
```

Captioned/labeled table (`{table}` wraps a pipe table):

```text
:::{table} My caption
:label: tbl-demo
:align: center

| foo | bar |
| --- | --- |
| baz | bim |
:::
```

**list-table** (each top-level `*` is a row; nested `-` are cells):

````text
```{list-table} Title here
:header-rows: 1
:label: tbl-list
:align: center
:widths: 30 70

* - Header A
  - Header B
* - row1 cell
  - row1 cell
* - row2 cell
  - row2 cell
```
````

`{csv-table}` (`:header: "A","B"`) also exists for inline CSV.

---

## Code

Fenced (no execution, just highlight):

````text
```python
import numpy as np
np.zeros(3)
```
````

`{code}` directive (aliases `code-block`, `sourcecode`) with options:

````text
```{code} python
:label: my-program
:caption: Build a mesh
:linenos:
:lineno-start: 1
:emphasize-lines: 2,4
:filename: example.py
import numpy as np
a = np.arange(10)
b = a * 2
print(b)
```
````

`{code-cell}` = executable (Jupyter / `myst start --execute`); accepts the same line options:

````text
```{code-cell} python
:label: cell-1
import numpy as np
print(np.pi)
```
````

`{literalinclude}` pulls in an external file:

````text
```{literalinclude} myst.yml
:start-at: project
:end-before: references
:linenos:
:lineno-match:
```
````

---

## Cross-references (internal)

**Define a target** — a label on its own line immediately before a header or block:

```text
(my-section)=
## My Section

(my-para)=
This labeled paragraph can be referenced too.
```

Or via a directive `:label:` (figures, tables, math, code, etc.).

**Reference it** — the mystmd way is a **Markdown link to `#label`** (auto-fills number/title if text omitted):

```text
[](#my-section)              <!-- auto text from target -->
[See the figure](#fig-demo)  <!-- custom text -->
@my-section                  <!-- @ shorthand -->
[](./other-file.md)          <!-- link a whole page → auto-fills its frontmatter title -->
```

> **Legacy (avoid in new content):** the Sphinx-style roles `` {ref}`label` ``,
> `` {ref}`Custom text <label>` ``, `` {numref}`Figure %s <fig-demo>` ``, `` {eq}`my-eq` `` still
> resolve, but the Markdown-link / `@` forms above are the current idiom. Don't mix them into new pages.

`%s` / `{number}` / `{name}` are placeholders filled from the target (in the `{numref}` template form).

---

## Links: pages, external, protocols

```text
[other page](./other-file.md)        <!-- link another source file -->
[text](https://example.com)          <!-- external -->
<https://example.com>                <!-- autolink -->
[text][ref]                          <!-- reference-style -->

[ref]: https://example.com
```

`{doc}` / `{download}` roles, and protocol links:

```text
{doc}`./other-file.md`
{download}`./data.zip`

<wiki:Gravitational_wave>            [text](wiki:Page_Title)
<doi:10.5281/zenodo.6476040>         [](doi:10.5281/zenodo.6476040)
[](xref:python#library/abc)          <!-- intersphinx-style xref -->
[](rrid:SCR_008394)                  [](ror:03rmrcq20)
```

> ⚠️ **Static files (PDF, zip, data, images-as-download) need the `{download}` role — NOT a
> plain `[](file.pdf)` link.** A Markdown link resolves as a reference to a *page* (`.md`/`.ipynb`);
> point it at a binary and MyST reports **"Document not found"** and never copies the file. Use
> `` {download}`Label <./report.pdf>` `` — that registers the file as a build asset (copied into the
> served `public/` dir, hashed) and renders a working download link. (Plain `[](./other.md)` is fine
> for *pages*; it's only non-page files that need `{download}`.)

---

## Citations & bibliography

```text
@cockett2015                 narrative (author-year inline)
[@cockett2015]               parenthetical
[@cockett2015; @heagy2017]   multiple
[e.g. @cockett2015, pg. 22]  with prefix/suffix
[-@cockett2015]              year only
@10.1093/nar/22.22.4673      cite by DOI directly
```

Sphinx-compatible roles also work: `` {cite:p}`key` `` (parenthetical), `` {cite:t}`key` `` (textual).

Register the `.bib` in **`myst.yml`** (project) or page frontmatter:

```yaml
# myst.yml
project:
  bibliography:
    - references.bib
```

A `# References` section + `:::{bibliography}:::` is rendered automatically; cited entries appear without an explicit directive in most themes.

---

## Roles at a glance (inline)

| Role | Use |
| --- | --- |
| `{sub}` / `{sup}` | subscript / superscript |
| `{abbr}` | `` {abbr}`MyST (Markedly Structured Text)` `` hover tooltip |
| `{kbd}` | keyboard key |
| `{del}` `{u}` `{sc}` | strikethrough / underline / small caps |
| `{ref}` `{numref}` `{eq}` | cross-references |
| `{cite:p}` `{cite:t}` | citations |
| `{doc}` `{download}` | link / link-to-download a file |
| `{button}` | clickable button (`` {button}`Text <target>` ``) |
| `{math}` | inline math (or `$...$`) |
| `{span}` | styled inline span with classes/id |
| `{term}` | link to a `{glossary}` entry |

## Directives at a glance

| Directive (aliases) | Use |
| --- | --- |
| `note` `tip` `important` `hint` `seealso` `attention` `caution` `warning` `danger` `error` | admonitions |
| `admonition` | custom-titled admonition (`:class:`) |
| `dropdown` | collapsible panel (`:open:`) |
| `card` | card (`^^^` header / `+++` footer / `:link:`) |
| `grid` + `grid-item` / `grid-item-card` | responsive layout grid |
| `tab-set` + `tab-item` | tabs (`:sync:`) |
| `figure` / `image` | figures / images (`:label:` `:width:` `:align:` `:alt:`) |
| `table` / `list-table` / `csv-table` | tables (`:header-rows:` `:label:` `:widths:`) |
| `code` (`code-block`, `sourcecode`) / `code-cell` | code (`:linenos:` `:emphasize-lines:` `:caption:`) |
| `include` (`literalinclude`) | embed external file |
| `math` | display equation (`:label:`) |
| `mermaid` | Mermaid diagram |
| `aside` (`margin`, `sidebar`, `topic`) | side content |
| `blockquote` (`epigraph`, `pull-quote`) | quotes |
| `bibliography` / `glossary` | references / term glossary |
| `embed` / `iframe` | reuse content / embed page |
| `toc` (`tableofcontents`, `toctree`, `contents`) | table of contents |
| `proof` `theorem` `lemma` etc. | proof-family blocks **(verify per theme/extension)** |

---

## Frontmatter

**Page frontmatter** (top of an `.md`/`.ipynb` file):

```yaml
---
title: Machine Learning Fundamentals
short_title: ML Basics          # ≤40 chars, for nav
subtitle: A gentle intro
label: ml-page                  # cross-ref target for the page
description: One-line summary (≤500 chars)
date: 2026-06-06                # ISO 8601
authors:
  - name: Jane Smith
    orcid: 0000-0001-2345-6789
    affiliations:
      - institution: SDSU
        department: Astronomy
tags: [tutorial, ml]
keywords: [neural-networks, supervised-learning]
bibliography: [references.bib]
license: CC-BY-4.0
math:                           # LaTeX macros
  '\Rsun': 'R_\odot'
abbreviations:
  MyST: Markedly Structured Text
numbering:
  headings: true
kernelspec:
  name: python3
---
```

Page fields override project-level defaults for that page.

**Project / site config** lives in **`myst.yml`** (not page frontmatter):

```yaml
version: 1
project:
  id: my-project-id
  title: My Project
  bibliography:
    - references.bib
  toc:
    - file: index.md
    - file: chapter1.md
site:
  template: book-theme
  options:
    numbered_references: true
```

Project-only keys include `id`, `references` (intersphinx), `requirements`, `resources`, `social`, `jupyter`/`thebe`, plus `site:` for theme/build.

---

## New mystmd vs legacy Sphinx-MyST — gotchas

Things that changed; do NOT copy these from old MyST / `myst-parser` / Jupyter Book v1 docs:

1. **Cross-refs are Markdown links to `#label`** — `[](#my-label)` / `@my-label` are the idiomatic forms. The old `` {ref}`label` `` still works but is no longer the default style; targets are defined with `(label)=` before a header (same as before) but you rarely need the role.
2. **Colon fences `:::{name}` are first-class** for Markdown-content directives; backtick fences are for code-like content. Legacy MyST leaned on triple-backtick `` ```{directive} `` everywhere — still valid, but colon fences are now the recommended default and nest by adding fence chars (`::::`).
3. **Config is `myst.yml`, not `conf.py` / `_config.yml` + `_toc.yml`.** There is no `conf.py`; the TOC lives under `project.toc` in `myst.yml`. Sphinx extensions / `myst_enable_extensions` do not apply.
4. **Many extensions are on by default** (dollarmath `$...$`, deflists, tasklists, GFM tables, footnotes, smartquotes). Don't add `myst_enable_extensions` — that's a Sphinx/myst-parser concept that does nothing in mystmd.
5. **Citations use Pandoc-style `[@key]` / `@key`** directly in text, with `.bib` registered in `myst.yml`. The `` {cite:p}`...` `` role is supported for compatibility but `[@key]` is preferred; no `sphinxcontrib-bibtex` setup.
6. **Static files (PDF/zip/data) need `{download}`, not a Markdown link.** `[](file.pdf)` resolves as a *page* reference → **"Document not found"** and the file is never served. Use `` {download}`Label <./file.pdf>` `` to copy it into the build and get a working link. (Pages — `.md`/`.ipynb` — link fine with `[](./page.md)`.)
7. **The page title comes from frontmatter `title:` — don't also write a body `# H1`.** mystmd renders the frontmatter title as the page H1; a duplicate body `#` is demoted to a section heading. Start the body at `##`. Give a page a cross-ref target with frontmatter `label:` (or `(label)=` before a `##`).

Smaller ones: collapsible admonitions use `:class: dropdown` (+ `:open:`) rather than a Sphinx-design-specific syntax; buttons are a **role** `` {button}`Text <target>` `` (verify if you expected a `{button}` directive); external IDs use protocol links (`wiki:`, `doi:`, `xref:`, `rrid:`, `ror:`) unique to mystmd.
