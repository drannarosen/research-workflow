---
title: Math in MyST (mystmd) + mystmd Gotchas
type: reference
status: source-backed
updated: 2026-06-06
---

(myst-math-and-gotchas)=

# Math in MyST (mystmd) + mystmd Gotchas

> **Ground-truth URLs** (fetched 2026-06-06, current `mystmd.org/guide`):
> - Math: <https://mystmd.org/guide/math>
> - Cross-references: <https://mystmd.org/guide/cross-references>
> - Cross-references / numbering: <https://mystmd.org/guide/cross-references#numbering>
> - Frontmatter (math macros, numbering): <https://mystmd.org/guide/frontmatter>
> - Admonitions (dropdown): <https://mystmd.org/guide/admonitions>
> - Dropdowns, cards & tabs: <https://mystmd.org/guide/dropdowns-cards-and-tabs>
> - Typesetting overview: <https://mystmd.org/guide/quickstart-myst-markdown>
>
> **Renderer:** HTML math is rendered by **KaTeX** (not MathJax). KaTeX is fast but
> supports a *subset* of LaTeX — some packages/commands silently fail. Always write
> **real KaTeX/LaTeX math**, never monospace or unicode glyphs.
>
> Items flagged **(verify)** are where the guide is terse or the behavior is
> version-sensitive; confirm in a live `myst start` preview before relying on them.

---

## Part 1 — Math (example-first, copy-paste-ready)

### 1.1 Inline math

Two equivalent syntaxes (per <https://mystmd.org/guide/math>):

```md
Dollar signs: $Ax=b$
Math role:    {math}`e=mc^2`
```

Prefer the `{math}` role when your sentence also contains a literal dollar sign
(e.g. a price), to avoid accidental math parsing. Escape a stray dollar sign with
a backslash: `\$2.99`.

**Real-symbol inline examples (copy-paste):**

```md
The mixing-length parameter $\alpha_{\rm MLT}$ controls convective efficiency.
The ratio $L_{\rm nuc}/L_{\rm surf}$ measures thermal imbalance.
Monte-Carlo error scales as $1/\sqrt{N}$.
A solar mass is $M_\odot$ and the effective temperature is $T_{\rm eff}$.
We find $T_{\rm eff} \sim 5800\,\mathrm{K}$, with $M \times 2 \leq 10\,M_\odot$.
```

Renders the symbols α_MLT, L_nuc/L_surf, 1/√N, M_⊙, T_eff, ∼, ×, ≤ as proper math.

> **Spacing tip:** use `\,` for a thin space before units (`5800\,\mathrm{K}`), and
> `\mathrm{...}` (or `\rm`) for upright subscript text like `\rm eff`. KaTeX supports
> both `T_{\rm eff}` and `T_{\mathrm{eff}}`; `\mathrm` is the more portable form.

### 1.2 Display math

Three methods produce a display equation block. **Source: <https://mystmd.org/guide/math>** (verbatim).

**(a) `$$ ... $$` dollar math** (most common):

```md
$$
\frac{\partial \rho}{\partial t} + \nabla\cdot(\rho \mathbf{v}) = 0
$$
```

**(b) `{math}` directive** (gives `:label:` and per-target options):

````md
```{math}
:label: my-equation
w_{t+1} = (1 + r_{t+1}) s(w_t) + y_{t+1}
```
````

**(c) Raw AMS environment** (no fence/directive needed — see §1.4):

```md
\begin{equation}
\label{matrix}
Ax = b
\end{equation}
```

### 1.3 Labeled display equations + cross-referencing

There are **two label syntaxes** depending on how you wrote the equation. **Source: <https://mystmd.org/guide/math>** and **<https://mystmd.org/guide/cross-references>**.

**Label a `{math}` directive** — use the `:label:` option:

````md
```{math}
:label: continuity
\frac{\partial \rho}{\partial t} + \nabla\cdot(\rho \mathbf{v}) = 0
```
````

**Label a `$$` block or an AMS environment** — use `\label{...}` *inside* the math:

```md
$$
\nabla \times \vec{e} + \frac{\partial \vec{b}}{\partial t} = 0
$$ (maxwell)
```

> **(verify) two forms seen in the docs for `$$` labels:** the math page shows
> `$$ \label{maxwell} ... $$` (a `\label{}` *inside* the block) **and** elsewhere MyST
> commonly uses the trailing `$$ ... $$ (label)` form shown above. Both are documented
> patterns; the trailing `(label)` form is the idiomatic mystmd one. Confirm in preview.

**Cross-reference the equation** (all from <https://mystmd.org/guide/cross-references> and the math page) — these are equivalent ways to get a numbered link like "(3)":

```md
Markdown link:   [](#continuity)
eq role:         {eq}`continuity`
numref role:     {numref}`continuity`
numref + text:   {numref}`Eq. %s <continuity>`
ref role:        {ref}`continuity`
shorthand @:     @continuity
```

- `[](#label)` with **empty text** auto-fills the equation number.
- `{eq}`label`` is documented as "equivalent to `[](#label)`" and inserts the number in parentheses.
- `{numref}` lets you template the text with `%s` (or `{number}`), e.g. `{numref}`Eq. %s <continuity>` → "Eq. 3".

> **(verify)** Labels must not contain spaces and must not start with a number
> (this restriction is explicitly called out for the Jupyter Book / Sphinx path; safe
> to follow universally). Sub-equation labeling "does not yet work" per the math page —
> don't rely on referencing individual lines of a multi-line aligned block.

### 1.4 AMS environments (align, gather, cases, matrix)

**Source: <https://mystmd.org/guide/math>.** You can write raw AMS environments
directly in the Markdown body (no fence required) **or** inside a `$$ ... $$` block.

**Documented supported environments:**
`equation`, `multline`, `gather`, `align`, `alignat`, `flalign`,
`matrix`, `pmatrix`, `bmatrix`, `Bmatrix`, `vmatrix`, `Vmatrix`, `eqnarray`.

**`align` (raw environment, auto-numbered + labelable):**

```md
\begin{align}
\label{maxwell-eqs}
\nabla \cdot \vec{E} &= \rho/\varepsilon_0 \\
\nabla \cdot \vec{B} &= 0
\end{align}
```

**`gather`:**

```md
\begin{gather}
a = b + c \\
x = y - z
\end{gather}
```

**`cases` (inside `$$`):** `cases` is **not** in the standalone-environment list above,
so wrap it in display math:

```md
$$
f(x) =
\begin{cases}
  x^2 & x \geq 0 \\
  -x  & x < 0
\end{cases}
$$
```

**`matrix` / `bmatrix`:**

```md
$$
\begin{bmatrix}
  a & b \\
  c & d
\end{bmatrix}
$$
```

> **Critical gotcha (from the math page):** the **`aligned`** environment (with the
> trailing "d") only works **inside** `\begin{equation}` or a `$$` block — it is *not*
> a standalone environment. Use `align` (no "d") for a top-level multi-line block,
> and `aligned` only nested inside `$$`/`equation`.

### 1.5 Math macros / custom commands (frontmatter + project)

**Source: <https://mystmd.org/guide/math> and <https://mystmd.org/guide/frontmatter>.**

**Page-level** — define in the page's YAML frontmatter under `math:`:

```yaml
---
math:
  '\RR': '\mathbb{R}'
  '\dobs': '\mathbf{d}_\text{obs}'
  '\dpred': '\mathbf{d}_\text{pred}\left( #1 \right)'
---
```

Then in the body:

```md
The reals are $\RR$. We compare $\dobs$ against $\dpred{m}$.
```

**Project-wide** — define once in `myst.yml` under `project.math:` (pages can override):

```yaml
# myst.yml
version: 1
project:
  math:
    '\RR': '\mathbb{R}'
    '\Msun': 'M_\odot'
    '\Teff': 'T_{\rm eff}'
```

**Rules (verbatim guidance from the docs):**

- **Use single quotes** in YAML so you don't have to escape backslashes.
- **The key includes the leading backslash** (`'\RR'`, not `'RR'`).
- **Arguments** are `#1`, `#2`, … in the definition, and are **invoked with braces**:
  `\dpred{m}` (not `\dpred m`).
- Frontmatter `math:` behavior is "page can override project."

### 1.6 `\text{}`, units, and chemistry

- **`\text{}`** is supported by KaTeX and used throughout the docs (e.g.
  `\mathbf{d}_\text{obs}`). For upright units prefer `\mathrm{...}` or `\,\mathrm{K}`.
- **mhchem / chemistry:** **(verify)** — the current math guide does **not** document a
  built-in `\ce{...}` (mhchem) extension. KaTeX *can* support mhchem only if the
  extension is loaded; mystmd does not advertise it on the math page. Do **not** assume
  `\ce{}` works — test in preview, and if it fails, write reactions with `\text{}` and
  `\rightarrow`. If chemistry support is needed, check for a `myst.yml` extension/plugin.

### 1.7 Equation numbering control

**Source: <https://mystmd.org/guide/cross-references#numbering>** and frontmatter page.
Numbering is configured in frontmatter or `myst.yml` (page can override project):

```yaml
# turn everything on / off
numbering: true
numbering: false
```

```yaml
# granular — note plural keys as documented
numbering:
  equation: false      # or true
  headings: true
  heading_1: true
  heading_2: true
  code: false
```

Numbering applies to: `figure`, `subfigure`, `equation`, `subequation`, `table`,
`code`, `headings`, and `heading_1`…`heading_6`. Advanced templating exists, e.g.:

```yaml
numbering:
  enumerator: A1.%s          # custom enumerator across components
  figure:
    template: fig (%s)
    continue: true           # continuous numbering across pages
```

> **(verify) singular vs plural keys:** the guide's granular example shows
> `equations: false`/`headings: true` (plural) in one place and `heading_1`
> (singular-with-index) elsewhere; the supported-component list uses singular
> `equation`. mystmd has accepted both at times — confirm which your installed version
> honors by checking the preview's equation numbers.

---

## Part 2 — Gotchas: new mystmd vs legacy Sphinx-MyST

mystmd is a **superset of CommonMark** "inspired by" Sphinx/RST — it is **not** the
`myst-parser` Sphinx plugin. Many patterns copied from Sphinx / Jupyter-Book-on-Sphinx
docs do not translate. Key differences a writer must know:

1. **Collapsible admonitions: `:class: dropdown`, not sphinx-design `{dropdown}` only.**
   Source: <https://mystmd.org/guide/admonitions>. To collapse a *typed* admonition,
   add the `dropdown` class (and `:open:` to start expanded):

   ````md
   ```{note}
   :class: dropdown
   This note starts collapsed.
   ```
   ````

   mystmd *also* ships a separate, simpler **`{dropdown}`** directive (below). Both exist;
   the `:class: dropdown` route is the one that turns a real admonition collapsible.

2. **`{dropdown}` directive** (compact, no admonition styling). Source:
   <https://mystmd.org/guide/dropdowns-cards-and-tabs>:

   ```md
   :::{dropdown} Dropdown Title
   :open:
   Dropdown content
   :::
   ```

   Note the **colon-fence** form (`:::{...}`) is idiomatic in mystmd alongside the
   backtick form; both are valid.

3. **Cards & grids differ from sphinx-design.** Source:
   <https://mystmd.org/guide/dropdowns-cards-and-tabs>:

   ```md
   ::::{grid} 1 1 2 3
   :::{card} Card title
   :link: https://mystmd.org
   Card content
   :::
   ::::
   ```

   - `{grid}` takes **four column counts** (small, medium, large, xl screens).
   - mystmd supports sphinx-design's `^^^` (header) and `+++` (footer) markers, **but**
     headers/footers are **optional** — omit the markers and they simply don't render
     (no empty header bar). Use `:header:` / `:footer:` / `:link:` options too.

4. **Admonition set is fixed at ten types.** Source:
   <https://mystmd.org/guide/admonitions>: `{note} {attention} {important} {caution}
   {hint} {warning} {seealso} {danger} {tip} {error}`. Don't expect arbitrary
   Sphinx admonition classes beyond these (use the generic `{admonition}` with a custom
   title for anything else).

5. **Cross-references use Markdown-link / role syntax, not RST `:ref:` targets.**
   Define a label with **`(my-label)=`** placed *before* a block (heading, equation,
   any node), then reference with `[](#my-label)`, `{ref}`, `{numref}`, `{eq}`, or the
   shorthand **`@my-label`**. Empty link text auto-fills "Figure 1" / "Eq. 3" / section
   title. This `@target` shorthand and auto-filled link text are **mystmd-specific** and
   absent from legacy Sphinx-MyST.

6. **Numbering is frontmatter/`myst.yml`-driven**, not `:numbered:` toctree flags.
   Equation/figure/heading numbering is turned on via the `numbering:` object (§1.7),
   not via Sphinx toctree options or `numfig = True` in `conf.py`.

7. **No `conf.py`.** Configuration is **`myst.yml`** (YAML), not a Python `conf.py`.
   Project-wide math macros, numbering, TOC, and site config all live there.

8. **Common Sphinx directives that are NOT part of core mystmd** (don't copy blindly):
   `{toctree}` (TOC is defined in `myst.yml`), `{eval-rst}` / raw RST, most
   `sphinx.ext.*` autodoc/intersphinx directives, and arbitrary third-party Sphinx
   extension directives. **(verify)** Some have mystmd equivalents or plugins; if a
   directive isn't in the mystmd guide, assume it is unsupported until confirmed in
   preview.

9. **KaTeX, not MathJax.** Math that relied on MathJax-only macros/packages can fail
   silently or render `??`. Stick to KaTeX-supported commands; test unusual constructs
   (`\substack`, `\mathscr`, custom packages, mhchem `\ce{}`) in a live preview.

10. **`aligned` (with "d") is nested-only** (repeated from §1.4 because it bites people):
    top-level multi-line math uses `align`/`gather`; `aligned` must sit inside
    `$$ ... $$` or `\begin{equation}`.

11. **Sub-equation references are not (yet) supported** — labeling individual lines of an
    aligned block to cross-reference them "does not yet work" per the math page.

12. **CLI basics** (the mystmd toolchain, not `sphinx-build`):
    - `myst start` — live dev server with hot reload (browse at `http://localhost:3000`).
    - `myst build` — build outputs; `myst build --html` (static site),
      `myst build --pdf` / `--tex` / `--docx` for exports.
    - `myst init` — scaffold a `myst.yml`.
    Math export to **Typst/PDF** can take per-equation overrides via the `:typst:` option
    on the `{math}` directive (e.g. `:typst: root(3, x)` for `\sqrt[3]{x}`).

---

## Quick verbatim cheat-sheet

```md
Inline:            $\alpha_{\rm MLT}$   {math}`e=mc^2`
Display:           $$ E = mc^2 $$
Display + label:   $$ E = mc^2 $$ (energy)
Directive + label: ```{math}\n:label: energy\nE = mc^2\n```
Reference:         [](#energy)  {eq}`energy`  {numref}`Eq. %s <energy>`  @energy
Macro (page):      math:\n  '\RR': '\mathbb{R}'
Macro (project):   project:\n  math:\n    '\Msun': 'M_\odot'
Numbering:         numbering:\n  equation: true
Dropdown note:     ```{note}\n:class: dropdown\n...\n```
Dropdown directive: :::{dropdown} Title\n:open:\n...\n:::
```
