# Research Workflow

Domain-agnostic **research-coding workflow discipline** for computational science (the JAX/Python research family — gravax, stellax, progenax, radax, …), packaged as a Claude Code plugin. The human is the scientist-in-the-loop, PI-level collaborator, and supervisor; the skills enforce evidence-first execution, structural correctness over compatibility, falsifiability, and reproducible artifacts. Domain specifics (e.g. MESA parity) live in thin **lenses**, so the stances stay sharp while the suite stays general.

## Skills (17, by workflow phase)

| Phase | Skill |
|---|---|
| Collaborate | `researcher-in-the-loop` · `high-impact-checkpoint` |
| Scope | `minimal-falsifiable-slice` · `discriminating-experiment-design` |
| Build correctly | `ownership-and-structure` · `correct-cutover` |
| Verify | `evidence-first-execution` · `verification-gate` · `numerical-method-validation` · `gradient-validation` · `reference-parity-audit` · `adversarial-result-check` · `uncertainty-reporting-gate` |
| Record | `decision-log-and-commits` · `provenance-of-constants` |
| Reproduce | `artifact-first-reproducibility` · `reproducible-environment-contract` |

Each skill's `description` carries a "Don't use when… (→ sibling)" partition and a `## Related` block, so the suite reads as one ordered protocol. `reference-parity-audit` loads a domain lens when one exists (`lenses/mesa.md` and `lenses/nbody.md` ship; `lenses/rad-transfer.md` is added on first need).

## Hooks (enforcement)

The skills document the discipline; four **path-scoped, self-limiting** hooks (`hooks/hooks.json`) enforce it. Each stays inert outside research code (e.g. during course work or quick edits) and **fails open** on any error, so it never blocks legitimate work.

| Hook | Event | Fires on | Action |
|---|---|---|---|
| deletion gate | `PreToolUse(Bash)` | `rm` / `git rm` / `git clean` / `shred` | asks for confirmation before a destructive op |
| test-integrity | `PreToolUse(Edit/Write)` | edits to `test_*.py` / `tests/**` that loosen a tolerance, drop an `assert`, or add `skip`/`xfail` | asks before a test is weakened to pass |
| provenance | `PreToolUse(Edit/Write)` | new numeric literals in `*constants*`/`*calibration*`/`environment.py`/`defaults.py` with no citation | asks for a source (DOI/arXiv/Table/Eq.) |
| evidence-before-done | `Stop` (main agent only) | a code/test/result/build claim ("fixed / passing / converged / built") with no fresh command output in the turn | blocks until the verification command + output are shown |

> **Hooks load at session start — restart Claude Code after installing or updating the plugin to activate them.** Smoke tests: `bash hooks/tests/run_tests.sh`.

## Installation

This plugin is `research-workflow`; the dev marketplace (in `.claude-plugin/marketplace.json`) is `research-workflow-dev`. Public repo: <https://github.com/drannarosen/research-workflow>.

```bash
git clone https://github.com/drannarosen/research-workflow.git
# then, in Claude Code:
/plugin marketplace add ./research-workflow
/plugin install research-workflow@research-workflow-dev
```

Then **restart Claude Code** (hooks load at session start). The version is single-sourced in `.claude-plugin/plugin.json`; keep `marketplace.json` in sync.

## Status

Consolidated 2026-05-30 from a former 15-skill `scientific-workflow` plugin: the ownership cluster merged → `ownership-and-structure` + `correct-cutover`; the MESA pair → `reference-parity-audit` + `lenses/mesa.md`; decision + commit → `decision-log-and-commits`; the rest were renamed and de-stellarified into a domain-agnostic numerical-research substrate.

**v1.1.0** adds the `gradient-validation` skill (finite-difference grad-checks, NaN/zero-gradient traps) and the four enforcement hooks above, and refines every skill — sharper "Use when…" descriptions with sibling disambiguation, concrete computational-astrophysics worked examples, dedupe-by-pointer cross-references, and explicit hard-vs-adaptable stances.
