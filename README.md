# Research Workflow

Domain-agnostic **research-coding workflow discipline** for computational science (the JAX/Python research family — gravax, stellax, progenax, radax, …), packaged as a Claude Code plugin. The human is the scientist-in-the-loop, PI-level collaborator, and supervisor; the skills enforce evidence-first execution, structural correctness over compatibility, falsifiability, and reproducible artifacts. Domain specifics (e.g. MESA parity) live in thin **lenses**, so the stances stay sharp while the suite stays general.

## Skills (48, by workflow phase)

| Phase | Skill |
|---|---|
| Collaborate | `researcher-in-the-loop` · `high-impact-checkpoint` |
| Scope | `minimal-falsifiable-slice` · `discriminating-experiment-design` · `testing-strategist` |
| Build correctly | `ownership-and-structure` · `correct-cutover` · `numerical-precision` · `derivation-before-implementation` · `staleness-sweep` · `no-silent-except` |
| Verify | `evidence-first-execution` · `verification-gate` · `numerical-method-validation` · `gradient-validation` · `reference-parity-audit` · `adversarial-result-check` · `uncertainty-reporting-gate` · `plausibility-envelope` · `ai-self-distrust` · `seed-and-stochasticity` · `prior-sensitivity` · `systematic-error-hunting` · `no-stub-when-done` |
| Review *(audit written code/figures)* | `scientific-code-reviewer` · `numerical-methods-auditor` · `jax-code-validator` · `error-handling-reviewer` · `code-craft-reviewer` · `benchmark-generator` · `plot-faithfulness-inspector` |
| Record | `decision-log-and-commits` · `provenance-of-constants` · `experiment-tracking` · `data-provenance` · `data-io-validator` · `null-result-integrity` · `assumption-ledger` · `no-secrets-in-git` |
| Communicate *(docs & figures)* | `myst-expert` · `docs-writing-voice` · `myst-ci` · `interactive-figures` · `mystmd-plugin-dev` · `plot-design-inspector` · `publication-figure-validator` |
| Reproduce | `artifact-first-reproducibility` · `reproducible-environment-contract` |

Each skill's `description` carries a "Don't use when… (→ sibling)" partition and a `## Related` block, so the suite reads as one ordered protocol. `reference-parity-audit` loads a domain lens when one exists (`lenses/mesa.md` and `lenses/nbody.md` ship; `lenses/rad-transfer.md` is added on first need).

The **Review** and **Communicate** clusters and several MyST references were consolidated in v1.2.0 from the former `astro-code-review` and `myst` plugins (now retired) — see the Status section. MyST authoring skills ship co-located references (`myst-cheatsheet`, `math-and-gotchas`, `myst-projects-and-workflows`, `voice-fingerprint`, `page-anatomy`) and the shippable `mystmd-plugins/interactive.mjs` directive bundle.

## Hooks (enforcement)

The skills document the discipline; eight **path-/command-scoped, self-limiting** hooks (`hooks/hooks.json`) enforce it. Each stays inert outside research code (e.g. during course work or quick edits) and **fails open** on any error, so it never blocks legitimate work.

| Hook | Event | Fires on | Action |
|---|---|---|---|
| deletion gate | `PreToolUse(Bash)` | `rm` / `git rm` / `git clean` / `shred` | asks for confirmation before a destructive op |
| no-secrets-in-git | `PreToolUse(Bash)` | `git add`/`commit` that names a credential file (`.env`, `*.pem`, …) or stages a secret signature (AWS/GitHub/Slack/Google token, `PRIVATE KEY` block, `api_key=…`) | asks before a secret enters git history |
| test-integrity | `PreToolUse(Edit/Write)` | edits to `test_*.py` / `tests/**` that loosen a tolerance, drop an `assert`, or add `skip`/`xfail` | asks before a test is weakened to pass |
| no-silent-except | `PreToolUse(Edit/Write)` | new Python that catches an exception and does nothing (bare `except:`, or `except …: pass/…/continue`) | asks before an error is silently swallowed |
| myst-docs-hygiene | `PreToolUse(Edit/Write)` | MyST docs (`docs/**/*.md`, `myst.yml`) with legacy Sphinx-MyST syntax (`{toctree}`/`{eval-rst}`/autodoc/RST), or a page missing the house-minimum `title`+`description` frontmatter | asks before legacy/incomplete MyST docs land (pairs with the `myst@myst-dev` plugin) |
| provenance | `PreToolUse(Edit/Write)` | uncited numeric literals in constants/calibration files, **or** references to external datasets/checkpoints (data-file URLs, `data/raw/…`) with no source/version/checksum | asks for a source (DOI/arXiv/Zenodo/checksum) |
| evidence-before-done | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | a code/test/result/build claim ("fixed / passing / converged / built") with no fresh command output in the turn | blocks until the verification command + output are shown |
| no-stub-when-done | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | a completion claim ("implemented / complete / ready") while an edit this turn left a stub in code (`NotImplementedError`, `TODO`/`FIXME`, placeholder body) | blocks until the stub is finished or the scope is restated |
| jq sanity check | `SessionStart` | `jq` not on `PATH` | warns that the gates are inactive (they need `jq`) |

> **Hooks load at session start — restart Claude Code after installing or updating the plugin to activate them.** Smoke tests: `bash hooks/tests/run_tests.sh`.

**Prerequisite:** the hooks use [`jq`](https://jqlang.github.io/jq/). If `jq` is not on `PATH` they fail open (no-op) — so install it (`brew install jq`) for the gates to be active.

**Debugging:** the hooks are silent by default. To see when each fires and what it decided (`allow:* / ask:* / block:*`), set `RWF_HOOK_DEBUG=1`; entries append to `$RWF_HOOK_LOG` (default `${TMPDIR:-/tmp}/research-workflow-hooks.log`). Example:

```bash
export RWF_HOOK_DEBUG=1
tail -f "${TMPDIR:-/tmp}/research-workflow-hooks.log"
# 2026-06-15T22:41:48 [evidence] block:claim-without-evidence — All tests pass.
# 2026-06-15T22:41:48 [deletion] ask:destructive — rm -rf x
```

## Commands

Four slash commands give deliberate entry points (skills also auto-surface by description); each does more than restate a skill:

| Command | Does |
|---|---|
| `/checkpoint [action]` | Go/no-go before an expensive or irreversible run (`high-impact-checkpoint`). |
| `/parity <ref>` | Reference-parity audit vs. an external reference, loading the matching lens (`mesa`/`nbody`). |
| `/reproduce` | Capture a reproducibility contract — env lock, seeds, precision, input ids, commit. |
| `/hooks-debug [status\|tail\|on\|off]` | Inspect/enable the hook decision log (see **Debugging** above; enabling needs a `settings.json` env entry + restart). |

## Installation

This plugin is `research-workflow`; the dev marketplace (in `.claude-plugin/marketplace.json`) is `research-workflow-dev`. Public repo: <https://github.com/drannarosen/research-workflow>.

```bash
git clone https://github.com/drannarosen/research-workflow.git
# then, in Claude Code:
/plugin marketplace add ./research-workflow
/plugin install research-workflow@research-workflow-dev
```

Then **restart Claude Code** (hooks load at session start). The version is single-sourced in `.claude-plugin/plugin.json`; keep `marketplace.json` in sync.

## Development

CI (`.github/workflows/ci.yml`) runs on every push / PR: `shellcheck`, the consistency checks, and the hook smoke tests. Run the same locally before committing:

```bash
bash scripts/checks.sh         # version sync (plugin.json == marketplace.json) + skill/command/hook/lens lint
bash hooks/tests/run_tests.sh  # hook smoke tests (56 cases)
```

## Status

Consolidated 2026-05-30 from a former 15-skill `scientific-workflow` plugin: the ownership cluster merged → `ownership-and-structure` + `correct-cutover`; the MESA pair → `reference-parity-audit` + `lenses/mesa.md`; decision + commit → `decision-log-and-commits`; the rest were renamed and de-stellarified into a domain-agnostic numerical-research substrate.

**v1.1.0** added the `gradient-validation` skill (finite-difference grad-checks, NaN/zero-gradient traps) and the first four enforcement hooks, and refined every skill — sharper "Use when…" descriptions with sibling disambiguation, concrete computational-astrophysics worked examples, dedupe-by-pointer cross-references, and explicit hard-vs-adaptable stances.

**v1.1.x** then grew the suite to 32 skills and added an epistemic-integrity set (derivation-before-implementation, plausibility-envelope, ai-self-distrust, null-result-integrity, the inference-robustness trio) plus four more deterministic gates (`no-silent-except`, `no-secrets-in-git`, `no-stub-when-done`, `myst-docs-hygiene`).

**v1.2.0** consolidates this into **one comprehensive research plugin**: the former **`astro-code-review`** plugin (11 of its 12 skills — `reproducibility-auditor` dropped as a duplicate of `reproducible-environment-contract` / `artifact-first-reproducibility`) and the former **`myst`** plugin (5 skills + the `interactive.mjs` directive bundle) were migrated in, adding the **Review** (computational-physics code/figure review) and **Communicate** (MyST docs + figure design/publication) clusters → **48 skills, eight enforcement hooks**. Both source plugins are retired (disabled, marked deprecated). MyST skills were re-scoped to research docs (teaching moved to the `sophie` platform).
