---
name: myst-ci
description: Use when deploying a MyST (mystmd) site or wiring cross-project references — scaffolding a GitHub Actions build/deploy to GitHub Pages, choosing version pinning + working directory, setting BASE_URL for project (sub-path) sites, and publishing `myst.xref.json` so other sites (e.g. the brain hub) can deep-link via `xref:`. Don't use for authoring page content (→ myst-expert / docs-writing-voice), a site's visual layout (the brain's brain-local brain-frontend skill), or writing `.mjs` plugins (→ mystmd-plugin-dev).
---

# MyST CI / deploy + cross-project xref

Deploy mystmd sites and connect them. The known-good recipe + the current federation state (what's
deployed vs not) is [references/ci-and-xref-patterns.md](references/ci-and-xref-patterns.md), distilled
from Anna's live workflows.

## Deploy recipe (GitHub Pages via Actions)

Canonical = stellax's split build/deploy workflow:

```yaml
permissions: {contents: read, pages: write, id-token: write}
concurrency: {group: pages, cancel-in-progress: true}
jobs:
  build:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4      # node 20
      - run: npm install -g mystmd       # pin (mystmd@1.8.3) for papers; latest for docs
      - working-directory: docs/website  # or docs/ ; or repo root
        run: myst build --html
      - uses: actions/upload-pages-artifact@v3
        with: {path: docs/website/_build/html}
  deploy:
    needs: build
    environment: github-pages
    steps: [{uses: actions/deploy-pages@v4}]
```

- **Working dir → artifact must match:** `docs/website/` → `docs/website/_build/html`.
- **Sub-path (project) sites need BASE_URL:** `env: {BASE_URL: /${{ github.event.repository.name }}/}`
  or assets 404 on `*.github.io/<repo>/`.
- **`--strict`** as a clean-docs gate (astra does this).

### Gotchas
- **Set repo Settings → Pages → Source = "GitHub Actions"** (not a branch) — the #1 silent failure.
- `id-token: write` + `environment: github-pages` are mandatory for the OIDC deploy.
- Custom frontmatter → `error_rules: [{rule: valid-page-frontmatter, severity: ignore}]`.
- Notebook execution is off unless `myst build --execute` with a science env on the runner.

## Cross-project xref / federation (currently designed, not live)

State today: **no repo declares `project.references`**; `myst.xref.json` exists only as local
git-ignored `_build/` artifacts; few spoke sites are deployed yet. The brain has
the *intent* (a comment + `link-resolves: warn`) but no live links. To unblock the brain↔spoke
federation:

1. **Deploy the spoke** (stellax/progenax/…) with the workflow above; enable Pages = Actions.
2. Confirm `https://<spoke-site>/myst.xref.json` resolves (`curl` it).
3. In the **hub** `myst.yml`: `project: { references: { stellax: https://<spoke-site>/ } }`.
4. Deep-link from the hub: `[](xref:stellax#label)` or `xref:stellax/<label>`.
5. Keep `error_rules: [{rule: link-resolves, severity: warn}]` while spokes come online.

progenax / knowflow / atlas have a `myst.yml` but **no deploy workflow** — they need one before they can
federate.

## Hand-offs
- Page content → `myst-expert` / `docs-writing-voice`. `.mjs` plugins → `mystmd-plugin-dev`.
