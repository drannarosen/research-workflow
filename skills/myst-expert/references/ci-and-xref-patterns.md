---
title: "MyST CI/CD deploy + cross-project xref patterns"
type: reference
status: source-backed
updated: 2026-09-16
---
(myst-ci-patterns)=
# MyST CI/CD deploy + cross-project xref patterns

How to build and deploy `mystmd` sites to GitHub Pages, and how cross-project `xref` federation
between MyST sites works (a hub site deep-linking into several published project sites). The recipes
below come from working deploy workflows for paper sites, package docs, and course sites. Companion:
the project/site-config layer lives in `myst-expert/references/myst-projects-and-workflows.md` (the
`(myst-projects-and-workflows)=` anchor) and the upstream MyST guide on external references
(<https://mystmd.org/guide/external-references>).

## TL;DR

- **Deploy recipe** = two-job Pages workflow: `checkout → setup-node → npm install -g mystmd → myst build --html → upload-pages-artifact(_build/html) → deploy-pages`. Node 20–22.
- **Version pinning**: paper sites pin (e.g. `mystmd@1.8.3`); package and course docs install **latest** (`mystmd`).
- **Working dir**: commonly `docs/website/` for package docs; `docs/` for a paper repo; **repo root** for a course site.
- **Artifact path** = `<workdir>/_build/html` (or repo-root `_build/html`).
- **xref federation** only works between **deployed** sites: each exposes `myst.xref.json` at its root. A `myst.xref.json` that exists only in a local `_build/` does not federate.

---

## 1. The known-good deploy workflow (canonical, minimal)

Use this as the template for any new package-docs site. Drop it at
`.github/workflows/deploy-docs.yml` and set `working-directory` / `path` to match the site location
(here `docs/website`).

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
- `concurrency.group: pages` serializes deploys. `cancel-in-progress: true` suits living docs; `false` (don't cancel an in-flight publish) suits a paper site. Either is fine; pick `false` if a half-deployed site is worse than a slow one.
- Split **build** and **deploy** jobs so the artifact upload is the handoff — this is the GitHub-recommended Pages pattern.
- `paths:` filter means the site only rebuilds on relevant changes (docs + source + the workflow itself).

### One-time repo setup (the gotcha that isn't in the YAML)
GitHub Pages must be set to **"Build and deployment → Source: GitHub Actions"** in repo Settings (not "Deploy from a branch"). Without this, `deploy-pages` has no Pages environment to publish to and the job errors. This is per-repo and is *not* captured in any workflow file — it is the most common reason a copied-in workflow "does nothing."

---

## 2. Version-pinning guidance

| Site type | Install line |
|---|---|
| **Package docs / course site** | `npm install -g mystmd` (latest) |
| **Paper / manuscript companion** | `npm install -g mystmd@1.8.3` (pinned) + `myst --version` verify step |

Rule of thumb: **pin for papers** (a manuscript build must be byte-reproducible across the submission
window), **latest for living docs** (you want new MyST features and fixes). When pinning, add the
verify step so a silently-wrong cache surfaces:

```yaml
- name: Install mystmd
  run: npm install -g mystmd@1.8.3
- name: Verify mystmd
  run: myst --version
```

**Node version**: 18.x, 20, and 22 all build MyST sites; **prefer 20 or 22** for new sites (18 is
EOL). For a Node-lockfile-driven repo use `node-version-file: .nvmrc` in `actions/setup-node`.

---

## 3. Working-directory & artifact-path conventions

The single most error-prone variable. Three layouts are common:

| Layout | Build invocation | Artifact path | Typical use |
|---|---|---|---|
| **`docs/website/`** | `working-directory: docs/website` → `myst build --html` | `docs/website/_build/html` | package docs |
| **`docs/`** | `defaults.run.working-directory: docs` → `myst build --html` | `docs/_build/html` | paper repo |
| **repo root** | `myst build --html` (no workdir) | `_build/html` | course site |

`_build/html` is **always** relative to wherever `myst build` runs. Two ways to set the dir:
- per-step `working-directory: docs/website`
- job-level `defaults: {run: {working-directory: docs}}`

A third option is to `cd docs/website` inside a `run:` block. Extra build flags worth knowing:
`myst build --site --html --strict` — `--strict` fails CI on any build warning (good gate for docs
that must stay clean).

---

## 4. Course-site extras — BASE_URL, notebooks, PDFs

A course site served at `https://<org>.github.io/<repo>/` (a project-pages **subpath**, not a root
domain) needs a base URL:

```yaml
env:
  # Set BASE_URL if your site is served under a subpath (e.g. /repo-name)
  BASE_URL: /${{ github.event.repository.name }}/
```

MyST reads the `BASE_URL` environment variable automatically and rewrites asset/link paths to that
prefix. **This is the fix for the "CSS/links 404 on GitHub Pages project sites" gotcha.** Any
project-pages MyST site (i.e. anything not on a custom domain or a `<org>.github.io` root repo)
should set this env — package-docs workflows need it too if served at `<org>.github.io/<repo>/`.

Other patterns seen in course-site deploys:
- A single combined `deploy` job (not split build/deploy) with `actions/configure-pages@v3` first also works.
- A Python toolchain installed (`setup-python@v4`, py 3.10) + `pip install -r requirements.txt` so notebooks *could* execute — while the build stays deliberately **no-execute** (`myst build --html`), leaving execution to readers in-browser via Thebe/Binder. Add `--execute` only when the CI runner has the science environment.
- Typst/PDF export can be left commented out; if PDFs are enabled, a copy step folds `_build/exports/*` into `_build/html/exports/` so they ship with the site.

---

## 5. Cross-project xref / federation

### 5a. The mechanism
A deployed MyST site exposes a machine-readable **`myst.xref.json`** at its root (and `.json` on any
page URL gives that page's AST). To deep-link *into* another project you:

1. Declare the external site under `project.references` in your `myst.yml`, keyed by a short name —
   the value **must be the URL of a deployed site**, not a local path:
   ```yaml
   project:
     references:
       pkg-a: https://<org>.github.io/<repo-a>/
       pkg-b: https://<org>.github.io/<repo-b>/
   ```
2. Link with the `xref:` protocol: `[](xref:pkg-a#<label>)` or `<xref:pkg-a/<path>#<target>>`.
   With no link text, MyST generates it from the remote at build time and renders a hover tooltip.
3. References are cached under `_build/`; `myst clean --cache` forces a re-fetch.

Source: the MyST guide on external references (<https://mystmd.org/guide/external-references>).

### 5b. Common "why doesn't it resolve" states

- **`myst.xref.json` exists only as a local build artifact.** Every `myst build` writes one under
  `_build/`, but that is a git-ignored output, not a deployed URL; it does not federate.
- **The referenced site isn't published yet.** A hub can be *pre-wired to tolerate* this: set
  `error_rules: [{rule: link-resolves, severity: warn}]` so unresolved future links warn rather than
  fail, and link to local stub pages until the project sites publish.
- **Custom domain vs. subpath.** Without a `CNAME` (or with `site.domains: []`), a site lives at
  `<org>.github.io/<repo>/` and needs `BASE_URL` (§4) for its assets and `myst.xref.json` to resolve.

### 5c. Step-by-step to wire hub ↔ project federation

For **each project site** you want to reference:

1. **Add the deploy workflow** (§1) to the project if missing, pointing at its site directory
   (e.g. `docs/website`). A repo with a `myst.yml` but no deploy workflow publishes nothing.
2. **Enable Pages → Source: GitHub Actions** in the repo settings (§1 one-time gotcha).
3. If the site is served at a subpath (`<org>.github.io/<repo>/`), **set `BASE_URL`** in its
   workflow env (§4) so the published site — and its `myst.xref.json` — resolve correctly.
4. **Confirm the live xref endpoint**: after deploy, `curl https://<site>/myst.xref.json` must return
   JSON. That URL (the site root, trailing slash) is what goes in `references`.
5. **Wire the consumer.** In the hub's `myst.yml` add:
   ```yaml
   project:
     references:
       pkg-a: https://<org>.github.io/<repo-a>/   # site root, trailing slash
       pkg-b: https://<org>.github.io/<repo-b>/
     # keep error_rules link-resolves: warn while sites roll out
   ```
6. **Author deep-links**: `[](xref:pkg-a#<label>)`. Use labels that exist in the remote (a
   page slug, a `(label)=` target, or a figure/equation id). Find them by opening the target page
   and copying the path + `#fragment` from the URL (per the MyST docs).
7. **Build**: `myst build --html` (locally first). First build fetches and caches each remote
   `myst.xref.json`; `myst clean --cache` to refresh after the remote changes.
8. Federation is **directional** — repeat the `references` block in any project that needs to link
   *back* to the hub or to a sibling. If only the hub aggregates, step 5 in the hub is all you need.

---

## 6. Gotcha checklist (deploy + config)

- **Pages source must be "GitHub Actions"**, set once per repo in Settings — not in YAML. #1 silent failure.
- **`id-token: write` + `environment: github-pages`** are mandatory for `deploy-pages@v4`/OIDC.
- **`BASE_URL: /${{ github.event.repository.name }}/`** for any project-pages (subpath) site, or assets/links 404.
- **Artifact path is relative to the build dir** — `docs/website/_build/html` vs `docs/_build/html` vs `_build/html`. Mismatched `upload-pages-artifact` path = empty/blank site.
- **`references` values must be deployed-site URLs**, never local paths; the site must actually expose `myst.xref.json` (verify with `curl`). Local `_build/myst.xref.json` does **not** federate.
- **Custom page frontmatter** (keys like `type`/`status`/`hat`) trips MyST's schema — silence with `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]`. Don't let it fail the CI build.
- **Unresolved future xref links**: set `error_rules: [{rule: link-resolves, severity: warn}]` so the build doesn't hard-fail while referenced sites are still rolling out.
- **`--strict`** turns warnings into build failures — great as a clean-docs gate, but only after the site builds warning-free.
- **Notebook execution is off by default** (`myst build --html`, no `--execute`); only add `--execute` once the CI runner has the science environment (e.g. JAX/NumPyro). Otherwise execution will fail or silently skip.
- **LFS**: if a site's figures are tracked with Git LFS, add `with: {lfs: true}` to `actions/checkout` or images won't be present at build time. Figures committed directly need nothing.

## Sources

- The MyST guide on external references (<https://mystmd.org/guide/external-references>) — upstream MyST xref / `myst.xref.json` docs.
- `myst-expert/references/myst-projects-and-workflows.md` — sibling project/site-config reference.
