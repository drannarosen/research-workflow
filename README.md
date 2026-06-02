# Research Workflow

Domain-agnostic **research-coding workflow discipline** for computational science (the JAX/Python research family — gravax, stellax, progenax, radax, …), packaged as a Claude Code plugin. The human is the scientist-in-the-loop, PI-level collaborator, and supervisor; the skills enforce evidence-first execution, structural correctness over compatibility, falsifiability, and reproducible artifacts. Domain specifics (e.g. MESA parity) live in thin **lenses**, so the stances stay sharp while the suite stays general.

## Skills (16, by workflow phase)

| Phase | Skill |
|---|---|
| Collaborate | `researcher-in-the-loop` · `high-impact-checkpoint` |
| Scope | `minimal-falsifiable-slice` · `discriminating-experiment-design` |
| Build correctly | `ownership-and-structure` · `correct-cutover` |
| Verify | `evidence-first-execution` · `verification-gate` · `numerical-method-validation` · `reference-parity-audit` · `adversarial-result-check` · `uncertainty-reporting-gate` |
| Record | `decision-log-and-commits` · `provenance-of-constants` |
| Reproduce | `artifact-first-reproducibility` · `reproducible-environment-contract` |

Each skill's `description` carries a "Don't use when… (→ sibling)" partition and a `## Related` block, so the suite reads as one ordered protocol. `reference-parity-audit` loads a domain lens when one exists (`lenses/mesa.md` ships; `lenses/nbody.md`, `lenses/rad-transfer.md` added on first need). Design + rationale: `~/brain/work/meta/comp-astro-suite-design.md`.

## Installation

> Install target is `<plugin-name>@<marketplace-name>`. This plugin is `research-workflow`; the dev marketplace (in `.claude-plugin/marketplace.json`) is `research-workflow-dev`. At packaging time this folds into the `comp-astro` family marketplace; the public name + GitHub handle are finalized then (not yet pushed).

```bash
# In Claude Code (local dev):
/plugin marketplace add /Users/anna/projects/claude-plugins/research-workflow
/plugin install research-workflow@research-workflow-dev
```

Then restart Claude Code. The version is single-sourced in `.claude-plugin/plugin.json`; keep `marketplace.json` in sync.

## Status

Consolidated 2026-05-30 from the former 15-skill `scientific-workflow` plugin (itself packaged from a global nested bundle Claude Code never loaded): 6 clusters merged (5-way ownership → `ownership-and-structure` + `correct-cutover`; MESA pair → `reference-parity-audit` + `lenses/mesa.md`; decision+commit → `decision-log-and-commits`), the rest renamed and de-stellarified to a domain-agnostic numerical-research substrate. Public packaging/push **deferred** per ADR-0010 §5 (with the `comp-astro` family marketplace) until daily use proves the suite.
