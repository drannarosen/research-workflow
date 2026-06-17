# Changelog

All notable changes to the **research-workflow** plugin are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/). The plugin version is single-sourced in
`.claude-plugin/plugin.json` (keep `marketplace.json` in sync).

## [Unreleased]

### Added
- **Skill-activation logging** (`hooks/skill_activation.sh`, `PreToolUse(Skill)`) — records each
  Skill-tool invocation as `[skill] invoke:<name>` into the `RWF_HOOK_DEBUG` log, so a week of data
  shows which of the 48 skills actually fire, not just the 8 hooks. Never blocks; silent unless
  `RWF_HOOK_DEBUG` is set. (Lower bound: captures explicit Skill-tool use, not silently-followed guidance.)
- **`/review` command** (`commands/review.md`) — deterministic entry point for the Review cluster:
  multi-lens scientific code/figure review of a changeset (correctness · numerics · JAX · robustness ·
  craft · figures), severity-tagged, with adversarial verification of each blocker. Promotes review from
  "hope a skill auto-surfaces" to "invoke it."
- **Self-staleness CI check** (`scripts/checks.sh`) — (7) fatal **dangling cross-reference** gate: every
  `(→ target)` arrow-redirect must resolve to an in-plugin skill or a known external (catches links to
  removed/migrated skills); (8) non-fatal **date-stamp staleness note** surfacing date-stamped references
  for review.

### Fixed
- Repointed stale cross-references left by the v1.2.0 migration: arrows to `astro-code-review` /
  `astro-code-dev` now point to the in-plugin Review/plot skills (or drop the non-skill pointer); the
  dropped `reproducibility-auditor` arrow removed. (Surfaced by the new dangling-cross-reference check.)
- Smoke tests → 58 (+2 for skill-activation logging).

## [1.2.0] — 2026-06-16

### Added
- **Consolidation into one comprehensive research plugin.** Migrated in the former **`astro-code-review`**
  plugin (11 of 12 skills) and the former **`myst`** plugin (5 skills + `mystmd-plugins/interactive.mjs`),
  adding two new phase clusters → **48 skills, eight enforcement hooks**:
  - **Review** (audit already-written code/figures): `scientific-code-reviewer`, `numerical-methods-auditor`,
    `jax-code-validator`, `error-handling-reviewer`, `code-craft-reviewer`, `benchmark-generator`,
    `plot-faithfulness-inspector`.
  - **Communicate** (docs & figures): `myst-expert`, `docs-writing-voice`, `myst-ci`, `interactive-figures`,
    `mystmd-plugin-dev`, `plot-design-inspector`, `publication-figure-validator`.
  - Also into existing phases: `testing-strategist` (Scope), `data-io-validator` (Record).
- **Dropped `reproducibility-auditor`** as a duplicate — its audit-an-existing-setup function is covered by
  `reproducible-environment-contract` + `artifact-first-reproducibility` + `seed-and-stochasticity` (the
  skills its own description already cited).
- MyST skills **re-scoped to research docs** (teaching/course/astr596 framing removed — teaching moved to the
  `sophie` platform); migrated `astro-code-review` SKILL files normalized CRLF → LF for the frontmatter lint.

### Changed
- Source plugins **`astro-code-review`** and **`myst`** are **retired**: disabled in settings and marked
  deprecated (repos left intact). research-workflow is now the single home for this discipline.
- Version → **1.2.0** (`plugin.json` + `marketplace.json`), promoting the prior `[Unreleased]` work below.

## [1.1.0-dev] — pre-consolidation (folded into 1.2.0)

### Fixed
- **Evidence-before-done gate now actually fires.** It read the final assistant message by parsing
  the transcript tail, but at Stop-hook fire time that message is not yet flushed — so it checked
  the *previous* turn's message and never blocked. It now reads `last_assistant_message` from the
  hook input (authoritative, race-free), with the transcript as a fallback for older Claude Code.
- **Evidence detection no longer false-allows.** It scanned the whole transcript tail for verb
  tokens (`validate`/`verify`/`pytest`/`PASSED`), so reading/displaying a file — or the gate's own
  source — counted as "evidence." It now requires an executed command (Bash) or Task delegation, or
  a numeric/structured pass-summary in a tool result.
- Evidence gate is subagent-safe (exits on `.agent_id`), so it never fires per-subagent.

### Added
- `LICENSE` (BSD-3-Clause), matching `plugin.json`.
- **Hook observability** — set `RWF_HOOK_DEBUG=1` to log each hook's decision
  (`allow:* / ask:* / block:*`) to `$RWF_HOOK_LOG` (default `${TMPDIR:-/tmp}/research-workflow-hooks.log`)
  via `hooks/_log.sh`. Silent and zero-cost by default; also records the `jq`-missing fail-open path.
- **Opt-in `SubagentStop` evidence gate** — set `RWF_SUBAGENT_EVIDENCE=1` to also gate a subagent's
  final code/test/result claims (off by default).
- **Data/input provenance check** in `provenance.sh` — flags edits that reference an external
  dataset/checkpoint (data-file URLs, or paths under `raw/data/inputs/datasets/catalogs/checkpoints`)
  with no visible source, version, or checksum.
- **Skills (3, → 20):** `experiment-tracking` and `data-provenance` (Record),
  `numerical-precision` (Build correctly).
- **Skills (6, → 26) — epistemic-integrity set:** `derivation-before-implementation` and
  `staleness-sweep` (Build correctly); `plausibility-envelope` and `ai-self-distrust` (Verify);
  `null-result-integrity` and `assumption-ledger` (Record). Target *confidently-wrong* outputs:
  derive math before coding it, sanity-bound every number, distrust AI-produced artifacts, record
  negatives honestly, hunt what a change falsified, and track load-bearing assumptions.
- **Skills (3, → 29) — inference-robustness set (Verify):** `seed-and-stochasticity` (judge
  stochastic results across an ensemble of seeds, never one lucky draw), `prior-sensitivity`
  (a Bayesian conclusion must survive a reasonable change of prior), `systematic-error-hunting`
  (hunt the unmodeled biases that shift the center without widening the bar). Cross-linked with
  `uncertainty-reporting-gate`.
- **Slash commands:** `/checkpoint`, `/parity`, `/reproduce`, `/hooks-debug`.
- **SessionStart `jq` sanity check** (`hooks/session_check.sh`) — warns (via additionalContext) when
  `jq` is missing, since without it every gate silently fails open. Silent when healthy.
- **CI** (`.github/workflows/ci.yml`) — runs `shellcheck`, the consistency checks, and the hook
  smoke tests on every push/PR.
- **`scripts/checks.sh`** — local/CI consistency checks: `plugin.json` ↔ `marketplace.json` version
  sync (the deployment-drift guard), plus skill/command/hook/lens lint.
- README: `jq` prerequisite, hook-debugging guide, Commands section, Development section. Hook smoke
  tests expanded to 30.

- **`no-silent-except` gate** (5th enforcement hook + backing skill, → 30 skills) — `PreToolUse(Edit/Write)` flags new
  Python that catches an exception and does nothing (bare `except:`, or `except …: pass/.../continue`),
  the silent-failure pattern that hides NaNs, non-convergence, and dropped data. Comment-guarded,
  path-scoped to `*.py`, fails open; backed by a thin `no-silent-except` skill (Build correctly).
- **`no-secrets-in-git` gate** (6th enforcement hook + backing skill, → 31 skills) — `PreToolUse(Bash)` flags a
  `git add`/`commit` that names a credential file (`.env`, `*.pem`, `id_rsa`, `credentials`, …) or stages a
  secret signature (AWS/GitHub/Slack/Google token, a `PRIVATE KEY` block, or an `api_key=…` assignment),
  scanning both the command string and the actual staged diff. High-precision so it never nags an ordinary
  commit; fails open when `jq`/`git` is missing or the path is not a repo. Backed by a `no-secrets-in-git`
  skill (Record).
- **`no-stub-when-done` gate** (7th enforcement hook + backing skill, → 32 skills) — `Stop` (and `SubagentStop`
  when `RWF_SUBAGENT_EVIDENCE` is set) blocks when the final message claims completion (implemented /
  complete / ready) while an Edit/Write this turn left a stub in a code file (`NotImplementedError`,
  `TODO`/`FIXME`/`XXX`, a placeholder body, or "not implemented"). Reuses the evidence gate's race-free
  `last_assistant_message` read and subagent-exemption policy. Backed by a `no-stub-when-done` skill (Verify).
- Hook smoke tests expanded to 48 (12 new: 7 for the secrets gate incl. real-repo staged-diff fixtures,
  5 for the stub gate).
- **`myst-docs-hygiene` gate** (8th enforcement hook) — `PreToolUse(Edit/Write)` on MyST docs
  (`docs/**/*.md`, `myst.yml`) flags legacy Sphinx-MyST syntax that mystmd silently does not support
  (`{toctree}`, `{eval-rst}`, autodoc directives, raw RST `.. dir::`, sphinxcontrib/intersphinx) and a
  page (or frontmatter block) missing the house-minimum `title`+`description`. Edit-time teeth that pair
  with the advisory `myst@myst-dev` plugin (page voice/structure rules stay there); fails open, path-
  scoped. No backing skill — the MyST knowledge home is the `myst` plugin (`myst-expert` /
  `docs-writing-voice`), which this hook cross-links instead of duplicating. Smoke tests → 56 (+8).
- Hardened the `debug: silent by default` smoke test to `env -u RWF_HOOK_DEBUG` so an ambient
  `RWF_HOOK_DEBUG` (e.g. exported from `settings.json`) can't mask the default-off assertion.

### Changed
- Synced `marketplace.json` plugin version to `1.1.0` to match `plugin.json` (was `1.0.0` — the drift
  that broke deployment); now enforced by the CI version-sync guard.

## [1.1.0]

### Added
- `gradient-validation` skill (finite-difference grad-checks, NaN/zero-gradient traps).
- Four enforcement hooks: test-integrity, deletion, evidence-before-done, provenance.

### Changed
- Refined every skill — sharper "Use when…" descriptions with sibling disambiguation, concrete
  computational-astrophysics worked examples, dedupe-by-pointer cross-references, explicit
  hard-vs-adaptable stances.

## [1.0.0]

### Added
- Initial release. Consolidated 2026-05-30 from the former 15-skill `scientific-workflow` plugin into
  a domain-agnostic numerical-research substrate (17 skills across collaborate / scope /
  build-correctly / verify / record / reproduce), with per-domain lenses for reference-parity work.
