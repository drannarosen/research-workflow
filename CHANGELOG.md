# Changelog

All notable changes to the **research-workflow** plugin are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/). The plugin version is single-sourced in
`.claude-plugin/plugin.json` (keep `marketplace.json` in sync).

## [Unreleased]

### Added
- `model-development` (Ideate; 70 → 71 skills): develop a researcher-derived model on its own terms before testing it. Sets the SCIENCE stance — **Explore / Develop / Critique / Test** — with a Develop protocol (restate in the researcher's notation → declared assumptions → derived consequences → missing closures and inconsistencies with ≥2 completions → next informative calculation) and a four-way issue taxonomy (unconventional assumption · untested prediction · mathematical inconsistency · empirical disagreement). Only a mathematical inconsistency interrupts Develop.

### Changed
- Resolved instructions that turned theoretical exploration into hypothesis testing prematurely:
  - `research-brainstorming` hard rule now applies once a claim or costly test is at stake; exploration is no longer an anti-pattern in itself.
  - `research-ideation` no longer generates rivals to a model the researcher has already chosen.
  - `discriminating-experiment-design` gains a "not yet" exit back to exploratory calculation.
  - `researcher-in-the-loop` names the stance first; the blocker/options/recommendation format is for decisions, not model development.
  - `derivation-before-implementation`, `provenance-of-constants`, `assumption-ledger`: a labeled *declared postulate* is a valid starting point/provenance and needs no literature citation.
  - `adversarial-result-check`: not for speculative models in development.
- `hooks/provenance.sh` accepts `declared postulate` / `assumption-ledger` as provenance tokens (+1 hook test).

### Fixed (2026-09-16 adversarial review — `docs/reviews/2026-09-16-adversarial-review.md`)
- **Hooks: SIGPIPE false-allow.** 18 `printf … | grep -q` pipelines under `pipefail` reported a *match* as a miss once input exceeded the pipe buffer — e.g. a secret in a large staged diff was silently allowed. Converted to here-strings; +10 >64 KB regression fixtures built with `jq --arg` (5 were deterministically RED on the old hooks). Same fix in `scripts/checks.sh`, which was nondeterministic.
- **Wrong technical content:** `gradient-validation` absolute FD step fails at CGS scale (now relative step; example prints `inf`, not NaN); worked examples in `ownership-and-structure`, `minimal-falsifiable-slice`, `discriminating-experiment-design`, `high-impact-checkpoint` replaced with physically correct ones; σ vs σ/√N for realization-level claims; retired R-hat 1.05; PSIS-LOO Pareto k̂; norm-dependent convergence order at discontinuities and adaptive-step symplecticity; license no longer decides formula correctness; `jax-code-validator` rewritten around behavior verified in JAX 0.11 (traced `if` raises, shape `if` works, unregistered dataclass fails, numpy RNG frozen at trace time); PNG is lossless; Zenodo version-DOI timing; residual-vs-error conditioning bound; missing pandas import; `jax.experimental.checkify` (not `jax.debug.check`).
- Removed an 86 MB `.mypy_cache` shipped inside `skills/gradient-validation/`; tool caches now gitignored.

### Added (batch E)
- **`inference_precision_gate.sh`** (9th hook, Stop/SubagentStop; ADR-0014): blocks a reported posterior estimate with an uncertainty but no R-hat/ESS in the message or turn output, and — in a JAX project — a reported error/drift/residual below ~1e-7 with no `jax_enable_x64` evidence. Exploratory/preliminary numbers are exempt. +16 fixtures.
- `scripts/checks.sh`: fails a skill description over the 1024-character Agent Skills limit and any unresolved `## Related` entry.

### Changed (review follow-up)
- Removed unverified journal column widths and Zenodo-specific release/DOI guidance (`software-citation` is now archive-agnostic; figure widths come from the journal TeX template).
- **Gates scoped to claims.** Record-keeping and verification gates apply to numbers that are reported, compared across sessions, or shipped; exploratory calculations are exempt and labeled. `high-impact-checkpoint` stops only for ownership/API/canonical-lane changes and runs above the project cost threshold — sweeps and >2-minute runs are announced. `verification-gate` sized to the change; `evidence-first-execution` allows parallel read-only exploration; `provenance-of-constants` no longer flags pure mathematical factors; seeds recorded once (run record) and linked elsewhere.
- `no_stub_when_done.sh` scans only text edited this turn, so an unrelated pre-existing TODO no longer blocks "done".
- `model-development` adds a **physical-principle violation** category (causality, positivity, second law, conservation) that interrupts Develop like a mathematical inconsistency.
- **Consolidation 71 → 59 skills** (ADR-0013, supersedes ADR-0009's packaging): `figure-review`, `astro-plotting-craft` audit mode, `adversarial-result-check` lanes, `bayesian-inference-gate`, `literature-workflow`, `performance-measurement`, `scientific-code-reviewer` numerics lens. `/review` and cross-references updated.
- **`install_freshness.sh`** (SessionStart, warn-only): for a local directory-marketplace install, compares content hashes of the shipped trees with the source repo and tells the user to reinstall when they differ (the pinned version makes `plugin update` a no-op). +4 fixtures.
- **Stop hooks read the current turn, not the last 250 transcript lines** (`hooks/_turn.sh`): evidence from an earlier turn no longer satisfies the evidence gate, and a long turn's early evidence is no longer missed. Hook feedback, system reminders, and task notifications are not turn boundaries. +3 fixtures; checked against a real 1702-line transcript.
- **Analytic checks are first-class development evidence.** `verification-gate` now has three stages — physics-checked, **analytic-checked** (closed form, manufactured solution, limiting case, known scaling; add the analytic-limit test when a term is added), externally validated (published result or reference code, at the end). Pointers updated in `numerical-method-validation`, `researcher-in-the-loop`, `scientific-code-reviewer`, `adversarial-result-check`.
- **Validation is staged.** New canonical *Validation stages* section in `verification-gate`: during development a number is **physics-checked** when its magnitude, units, scaling, limits, and conservation behavior make sense and the supervising scientist accepts it — no reference-code run or published-figure reproduction is required to keep building; **external validation** (analytic, published, or reference-code comparison) is required at or near the end, before a result is published, released, or called validated. `numerical-method-validation`, `reference-parity-audit`, `/parity`, `researcher-in-the-loop`, `ownership-and-structure`, `scientific-code-reviewer`, and `adversarial-result-check` point to it. Removed the REBOUND N-body parity lens stub.
- **Removed / moved (59 → 54).** `ai-self-distrust` → a rule in `researcher-in-the-loop`; `testing-strategist` → a diagnostics-planning section in `numerical-method-validation`; `error-handling-reviewer` deleted (covered by `no-silent-except` and the numerics lens; dropped from `/review`); `publication-figure-validator` → manuscript-workflow figure-polish protocol (ADR-0010); `data-management-plan` → grant-writing `grant-budget-and-docs` (ADR-0011).

## [1.5.0] — 2026-06-19

### Added
- **Figure craft & interpretation layer** (67 → 70 skills), completing the figure lifecycle:
  - `astro-plotting-craft` (Communicate) — author publication-grade astrophysics plots in Anna's house style: the jaxstroviz theme + figure helpers as source of truth, seaborn perceptually-uniform colormaps (`mako`/`vlag`), CVD-safe categorical palettes with color×marker redundancy, log/linear axis discipline, LaTeX-not-unicode labels with CGS/solar units, uncertainty and overlay handling. Ships co-located references (`house-style.md`, distilled `seaborn-plotting-reference.md`).
  - `plot-craft-reviewer` (Review) — audit existing plot *code*/figures for craft defects: wrong axis scale, unicode-vs-LaTeX, mathtext syntax errors, overlay/occlusion, off-brand or non-colorblind-safe colormaps, missing error bars/units. Auto-surfaces under `/review`.
  - `figure-interpretation-guard` (Verify) — what a finished figure lets you *conclude*: over-reading, visual traps (log/aspect/binning), reproducing & comparing paper figures like-for-like, AI-misread plots, and digitization provenance.
- House style matches the **jaxstroviz** package as-is (its theme architecture and minimalist rcParams are near-SoTA — kept verbatim); `house-style.md` documents it and names the SoTA upgrade targets the skills already enforce: a CVD-safe categorical palette (the current cycle has a red-green gap), color×marker redundancy, reproducible fonts (CM-Roman fallback risk), and a perceptually-uniform colormap policy. A teal/Inter aesthetic refresh is prototyped but optional/deferred.

## [1.4.1] — 2026-06-19

### Added
- Completes the v1.4.0 **Literature** cluster (deferred pending a boundary check against `manuscript-workflow:lit-scan`): `reading-notes-discipline` (per-paper claim/evidence/caveat intake with source pointers) and `related-work-map` (durable cross-paper field map maintained across a project). Skill count 65 → 67.
- Boundary confirmed clean by reading `lit-scan`: reading-notes = per-paper *intake*, related-work-map = cross-paper *synthesis you maintain*, prior-art-check = one-time *novelty gate*, lit-scan = per-manuscript *citation completeness* (different plugin, late stage).

## [1.4.0] — 2026-06-19

### Added
- **Ideate cluster** (front-of-funnel): `research-ideation` (divergent generation + triage of research directions) and `research-brainstorming` (Socratic refinement of one direction into a falsifiable hypothesis + discriminating observable).
- **Literature cluster**: `prior-art-check` (systematic novelty/closest-work search; positioned against `manuscript-workflow:lit-scan`).
- **Inference rigor cluster**: `mcmc-convergence-gate` (R-hat/ESS/divergences/BFMI), `predictive-checks` (prior + posterior predictive), `model-selection-discipline` (out-of-sample comparison; folds in forking-paths/multiple-comparisons guards).
- **Performance & scale cluster**: `profiling-discipline` (measure-first), `scaling-validation` (strong/weak scaling), `jax-performance` (recompilation/transfers/sharding), `cluster-run-contract` (HPC job→artifact provenance).
- **Reproduce & release tail**: `software-citation` (CITATION.cff/DOI/CRediT), `research-release-checklist` (semver, tag↔DOI↔paper, figure→artifact trace), `data-management-plan` (FAIR, repositories, licensing).
- Skill count 52 → 65. No new hooks; no skills renamed. New keywords: `bayesian-inference`, `mcmc`, `hpc`, `research-ideation`, `software-citation`.

## [1.3.1] — 2026-06-18

### Fixed
- Evidence-before-done no longer treats Task delegation as verification by itself; subagent/tool results now need a numeric pass summary or structured verification summary.
- No-stub-when-done now scans final touched code files, catching pre-existing stubs in files edited during the turn.
- `mystmd-plugins/interactive.mjs` now serializes directive inputs through JSON-safe script escaping instead of interpolating user strings into JavaScript literals.
- CI now runs official `claude plugin validate .`, and `scripts/checks.sh` enforces skill graph promises (`## Related` and negative trigger partitions).

## [1.3.0] — 2026-06-18

### Added
- Equation-critical source layer: `pdf-equation-extraction`, `equation-to-code-traceability`, `reference-license-firewall`, `equation-errata-ledger`, `/equation-digest`, and `equation-verifier`.

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
