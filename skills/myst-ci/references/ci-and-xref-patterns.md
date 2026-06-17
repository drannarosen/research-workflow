---
title: "MyST CI/CD deploy + cross-project xref patterns (Anna's stack)"
type: reference
status: source-backed
updated: 2026-06-06
---
(myst-ci-patterns)=
# MyST CI/CD deploy + cross-project xref patterns

How Anna's repos build and deploy `mystmd` sites to GitHub Pages, and how the brain↔spoke
cross-project `xref` federation is *meant* to work (vs. what is actually wired up today). Every
recipe below is lifted verbatim from a live workflow file — paths cited inline. Companion: the
project/site-config layer lives in
`myst/skills/myst-expert/references/myst-projects-and-workflows.md` (the `(myst-projects-and-workflows)=`
anchor) and the upstream MyST docs Anna keeps at
`/Users/anna/Teaching/astr596-f25/myst-md-docs/external-references.md`.

## TL;DR

- **Deploy recipe** = two-job Pages workflow: `checkout → setup-node → npm install -g mystmd → myst build --html → upload-pages-artifact(_build/html) → deploy-pages`. Node 20–22.
- **Version pinning**: papers pin (`mystmd@1.8.3`); package/course docs install **latest** (`mystmd`).
- **Working dir**: `docs/website/` for package docs (stellax, progenax, astra, sophie, knowflow, atlas); `docs/` for the paper repo; **repo root** for the astr596 course site.
- **Artifact path** = `<workdir>/_build/html` (or repo-root `_build/html`).
- **xref federation status**: **nothing is wired yet.** No repo declares `project.references`; the only deployed MyST site exposing `myst.xref.json` is the **astr596 course** (`astrobytes-edu.github.io/astr596-modeling-universe/`). The jaxstro spokes (stellax/progenax/sophie/paper) build `myst.xref.json` *locally* into `_build/` but never publish. That is exactly the brain backlog item "Deploy spoke MyST sites so real xref links resolve."

---

## 1. The known-good deploy workflow (canonical, minimal)

Source of truth: **`/Users/anna/projects/jaxstro-dev/stellax/.github/workflows/deploy-docs.yml`**.
This is the cleanest, most current pattern — use it as the template for any new package-docs site.
Drop it at `.github/workflows/deploy-docs.yml` and set `working-directory` / `path` to match the site
location (here `docs/website`).

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'docs/website/**'
      - 'src/<pkg>/**'                 # rebuild when API source changes too
      - '.github/workflows/deploy-docs.yml'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install MyST
        run: npm install -g mystmd

      - name: Build site
        working-directory: docs/website
        run: myst build --html

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs/website/_build/html

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**Why this shape (load-bearing details):**
- `permissions: {contents: read, pages: write, id-token: write}` + `environment: github-pages` are **required** for the OIDC-based `deploy-pages@v4` action. Omitting `id-token: write` fails the deploy.
- `concurrency.group: pages` serializes deploys; stellax uses `cancel-in-progress: true`, the paper repo uses `false` (don't cancel an in-flight publish). Either is fine; pick `false` if a half-deployed site is worse than a slow one.
- Split **build** and **deploy** jobs so the artifact upload is the handoff — this is the GitHub-recommended Pages pattern and all of Anna's MyST deploys follow it.
- `paths:` filter means the site only rebuilds on relevant changes (docs + source + the workflow itself).

### One-time repo setup (the gotcha that isn't in the YAML)
GitHub Pages must be set to **"Build and deployment → Source: GitHub Actions"** in repo Settings (not "Deploy from a branch"). Without this, `deploy-pages` has no Pages environment to publish to and the job errors. This is per-repo and is *not* captured in any workflow file — it is the most common reason a copied-in workflow "does nothing."

---

## 2. Version-pinning guidance

Drawn from the two real choices in the repos:

| Site type | Install line | Source file |
|---|---|---|
| **Package docs / course** (stellax, astra, astr596) | `npm install -g mystmd` (latest) | `stellax/.github/workflows/deploy-docs.yml:32`, `julia-dev/astra/.github/workflows/ci.yml:26`, `astr596-.../deploy.yml:50` |
| **Paper / manuscript companion** | `npm install -g mystmd@1.8.3` (pinned) + `myst --version` verify step | `papers/rosen-burkhart-swindle-2026/.github/workflows/build-docs.yml:36-39` |

Rule of thumb (matches the myst-expert reference): **pin for papers** (a manuscript build must be byte-reproducible across the submission window), **latest for living docs** (you want new MyST features and fixes). When pinning, add the verify step so a silently-wrong cache surfaces:

```yaml
- name: Install mystmd
  run: npm install -g mystmd@1.8.3
- name: Verify mystmd
  run: myst --version
```

**Node version**: 20 (stellax), 22 (paper repo `build-docs.yml:33`, astra `ci.yml:24`), 18.x (astr596 `deploy.yml:35`). All work; **prefer 20 or 22** for new sites (18 is EOL). For a Node lockfile-driven repo use `node-version-file: .nvmrc` (sophie's pattern, `sophie/.github/workflows/ci.yml`).

---

## 3. Working-directory & artifact-path conventions

The single most error-prone variable. Three layouts exist in the wild:

| Layout | Build invocation | Artifact path | Example repo |
|---|---|---|---|
| **`docs/website/`** (package docs) | `working-directory: docs/website` → `myst build --html` | `docs/website/_build/html` | stellax, progenax, sophie, knowflow, atlas, astra |
| **`docs/`** (paper) | `defaults.run.working-directory: docs` → `myst build --html` | `docs/_build/html` | `papers/rosen-burkhart-swindle-2026` |
| **repo root** (course) | `myst build --html` (no workdir) | `_build/html` | `astr596-modeling-universe` |

`_build/html` is **always** relative to wherever `myst build` runs. Two ways to set the dir, both used:
- per-step `working-directory: docs/website` (stellax)
- job-level `defaults: {run: {working-directory: docs}}` (paper repo `build-docs.yml:23-25`)

The astra repo (`julia-dev/astra/.github/workflows/ci.yml:42-45`) instead `cd docs/website` inside a `run:` block and builds with extra flags worth knowing: `myst build --site --html --strict` — `--strict` fails CI on any build warning (good gate for docs that must stay clean).

---

## 4. Course-site extras (astr596 pattern) — BASE_URL, notebooks, PDFs

Source: **`/Users/anna/Teaching/astr596-f25/astr596-modeling-universe/.github/workflows/deploy.yml`**.
This is the richest deploy and the one place a **subpath base URL** is handled — required when the site
is served at `https://<user>.github.io/<repo>/` rather than a root domain.

```yaml
env:
  # Set BASE_URL if your site is served under a subpath (e.g. /repo-name)
  BASE_URL: /${{ github.event.repository.name }}/
```

MyST reads the `BASE_URL` environment variable automatically and rewrites asset/link paths to that
prefix. **This is the fix for the "CSS/links 404 on GitHub Pages project sites" gotcha.** Any new
project-pages MyST site (i.e. anything not on a custom domain) should set this env. None of the
jaxstro spoke workflows currently set it — if their sites are served at
`drannarosen.github.io/<repo>/`, they will need it.

Other notable steps in that workflow:
- Single combined `deploy` job (not split build/deploy) with `actions/configure-pages@v3` first.
- Python toolchain installed (`setup-python@v4`, py 3.10) + `pip install -r requirements.txt` so notebooks *could* execute — but the build is deliberately **no-execute**: `myst build --html` with the comment "students can execute in-browser via Thebe/Binder." Add `--execute` only when the CI runner has the science env (the paper and astra workflows both note this deferral).
- Typst/PDF export is **commented out** ("PDF exports disabled per maintainer request"); there's a copy step that folds `_build/exports/*` into `_build/html/exports/` if PDFs are ever re-enabled.

---

## 5. Cross-project xref / federation — how it's meant to work, and the current state

### 5a. The mechanism (from MyST docs + Anna's notes)
A deployed MyST site exposes a machine-readable **`myst.xref.json`** at its root (and `.json` on any
page URL gives that page's AST). To deep-link *into* another project you:

1. Declare the external site under `project.references` in your `myst.yml`, keyed by a short name —
   the value **must be the URL of a deployed site**, not a local path:
   ```yaml
   project:
     references:
       stellax: https://<deployed-stellax-site>/
       progenax: https://<deployed-progenax-site>/
   ```
2. Link with the `xref:` protocol: `[](xref:stellax#<label>)` or `<xref:stellax/<path>#<target>>`.
   With no link text, MyST generates it from the remote at build time and renders a hover tooltip.
3. References are cached under `_build/`; `myst clean --cache` forces a re-fetch.

Source: `/Users/anna/Teaching/astr596-f25/myst-md-docs/external-references.md` (the `(myst-xref)=`
section, lines 21–95) and `myst-expert/references/myst-projects-and-workflows.md:90-101`.

### 5b. What is actually deployed today (ground truth, 2026-06-06)

- **No repo declares `project.references`.** Grep for `references:` (as a project key, not
  `bibliography`) across every `myst.yml` in projects/Teaching/brain returns **zero** hits.
- **The brain has the intent documented but not the config.** `/Users/anna/brain/myst.yml:6-9`
  carries only a comment:
  > "MyST cross-project `references` must be URLs of DEPLOYED MyST sites (each exposes
  > myst.xref.json). Spoke deep-links via `xref:` activate once stellax/sophie/progenax publish
  > their sites; meanwhile the hub links to project stubs and federate.py aggregates across repos."
  It sets `error_rules: [{rule: link-resolves, severity: warn}]` so unresolved future links warn
  rather than fail — the brain is *pre-wired to tolerate* xref links that don't resolve yet.
- **`myst.xref.json` exists only as a local build artifact**, never published: found under
  `brain/_build/`, `stellax/docs/website/_build/`, `progenax/docs/website/_build/`,
  `sophie/docs/website/_build/`, and the two paper repos' `_build/`. These are git-ignored build
  outputs, not deployed URLs.
- **The one genuinely deployed MyST site** that exposes xref is the **astr596 course**:
  `https://astrobytes-edu.github.io/astr596-modeling-universe/` (deployed via the workflow in §4;
  URL confirmed from links in `stellax/docs/website/STYLE_GUIDE.md:168-170`).
- **No custom domains**: no `CNAME` files anywhere; the paper repo sets `site.domains: []`
  (`papers/rosen-burkhart-swindle-2026/docs/myst.yml:115`).

So federation is **designed and tolerated but not active**. The blocker is purely that the spoke
sites aren't published to public URLs yet.

### 5c. Step-by-step to unblock brain↔spoke federation

For **each spoke** you want to reference (stellax, progenax, sophie, …):

1. **Add the deploy workflow** (§1) to the spoke if missing, pointing at its `docs/website`.
   (stellax already has `deploy-docs.yml`; progenax/knowflow/atlas have `myst.yml` but **no deploy
   workflow** — they need one.)
2. **Enable Pages → Source: GitHub Actions** in the spoke repo settings (§1 one-time gotcha).
3. If the spoke is served at a subpath (`drannarosen.github.io/<repo>/`), **set `BASE_URL`** in its
   workflow env (§4) so the published site — and its `myst.xref.json` — resolve correctly.
4. **Confirm the live xref endpoint**: after deploy, `curl https://<site>/myst.xref.json` must return
   JSON. That URL (the site root, trailing slash) is what goes in `references`.
5. **Wire the consumer.** In `brain/myst.yml` add:
   ```yaml
   project:
     references:
       stellax:  https://drannarosen.github.io/stellax/         # site root, trailing slash
       progenax: https://drannarosen.github.io/progenax/
     # error_rules already set link-resolves: warn (keep it while sites roll out)
   ```
6. **Author deep-links**: `[](xref:stellax#<label>)`. Use labels that exist in the remote (a
   page slug, a `(label)=` target, or a figure/equation id). Find them by opening the target page
   and copying the path + `#fragment` from the URL (per the MyST docs).
7. **Build**: `myst build --html` (locally first). First build fetches and caches each remote
   `myst.xref.json`; `myst clean --cache` to refresh after the remote changes.
8. Federation is **directional** — repeat the `references` block in any spoke that needs to link
   *back* to the brain or to a sibling. The brain↔spoke design currently only needs the brain to
   consume spokes (it aggregates), so step 5 in the brain is the primary unblock.

---

## 6. Gotcha checklist (deploy + config)

- **Pages source must be "GitHub Actions"**, set once per repo in Settings — not in YAML. #1 silent failure.
- **`id-token: write` + `environment: github-pages`** are mandatory for `deploy-pages@v4`/OIDC.
- **`BASE_URL: /${{ github.event.repository.name }}/`** for any project-pages (subpath) site, or assets/links 404. Only astr596 sets it today; jaxstro spokes will need it if served at a subpath.
- **Artifact path is relative to the build dir** — `docs/website/_build/html` vs `docs/_build/html` vs `_build/html`. Mismatched `upload-pages-artifact` path = empty/blank site.
- **`references` values must be deployed-site URLs**, never local paths; the site must actually expose `myst.xref.json` (verify with `curl`). Local `_build/myst.xref.json` does **not** federate.
- **Custom page frontmatter** (brain/sophie keys like `type`/`status`/`hat`) trips MyST's schema — silence with `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]` (brain `myst.yml:17-18`). Don't let it fail the CI build.
- **Unresolved future xref links**: set `error_rules: [{rule: link-resolves, severity: warn}]` (brain pattern) so the build doesn't hard-fail while spoke sites are still rolling out.
- **`--strict`** (astra) turns warnings into build failures — great as a clean-docs gate, but only after the site builds warning-free.
- **Notebook execution is off by default** in every workflow (`myst build --html`, no `--execute`); only add `--execute` once the CI runner has the JAX/numpyro science env. Otherwise execution will fail or silently skip.
- **LFS**: none of Anna's MyST repos use Git LFS for figures (no `lfs: true` on any `checkout` step, no `.gitattributes` LFS filters in the doc repos) — figures are committed directly. If a future site adds LFS-tracked figures, add `with: {lfs: true}` to `actions/checkout` or images won't be present at build time.

## Files cited

- `/Users/anna/projects/jaxstro-dev/stellax/.github/workflows/deploy-docs.yml` — canonical deploy (latest mystmd, Node 20, `docs/website`).
- `/Users/anna/projects/jaxstro-dev/papers/rosen-burkhart-swindle-2026/.github/workflows/build-docs.yml` — paper deploy (pinned `mystmd@1.8.3` + verify, Node 22, `docs/`).
- `/Users/anna/Teaching/astr596-f25/astr596-modeling-universe/.github/workflows/deploy.yml` — course deploy (BASE_URL subpath, Python/notebook toolchain, repo-root build).
- `/Users/anna/projects/julia-dev/astra/.github/workflows/ci.yml` — `myst build --site --html --strict` from `docs/website`.
- `/Users/anna/brain/myst.yml` — federation intent comment + `error_rules` (link-resolves warn, valid-page-frontmatter ignore); **no `references` block yet**.
- `/Users/anna/Teaching/astr596-f25/myst-md-docs/external-references.md` — upstream MyST xref / `myst.xref.json` docs.
- `myst/skills/myst-expert/references/myst-projects-and-workflows.md` — sibling project/site-config reference.
- Spoke `myst.yml` files (no `references`, no deploy workflow for progenax/knowflow/atlas):
  `progenax/docs/website/myst.yml`, `stellax/docs/website/myst.yml`, `knowflow/docs/website/myst.yml`,
  `papers/rosen-burkhart-swindle-2026/docs/myst.yml` (`domains: []`).
