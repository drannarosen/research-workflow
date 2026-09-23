# Research Workflow

Research-coding workflow for computational science, packaged as a Claude Code plugin. It was built for a JAX/Python astrophysics group, and its worked examples come from there (N-body dynamics, stellar structure), but the contracts are domain-agnostic.

The researcher is the PI-level collaborator who owns the science; the assistant derives, implements, runs, and reports. Three rules carry the design:

- **Scientific assumptions need the researcher's approval.** Closures, coefficients, approximations, regimes, boundary conditions, default parameters, and pass/fail tolerances are proposed with their physical motivation and wait for a yes (`researcher-in-the-loop`, `assumption-ledger`).
- **Experiments are derivation-backed.** A run is proposed with its motivation and a predicted outcome from a derivation or scaling argument, run once approved, and reported against the prediction.
- **Rigor scales with the stage of a result.** Exploratory numbers the researcher judges on magnitude and physics carry development; analytic checks are used whenever possible; comparison with published results or reference codes is due before a result is published or released (`verification-gate`, *Validation stages*).

Domain specifics live in thin **lenses** and **references** (e.g. `reference-parity-audit/lenses/mesa.md`, `numerical-method-validation/references/astro-nbody.md`), so the skills stay general.

## Skills (43, by workflow phase)

| Phase | Skill |
|---|---|
| Collaborate | `researcher-in-the-loop` *(stance · pre-run statement · direction · high-impact checkpoint)* |
| Ideate | `model-development` · `research-ideation` · `hypothesis-and-test-design` |
| Literature | `literature-workflow` *(intake · map · novelty)* |
| Scope | `minimal-falsifiable-slice` |
| Build correctly | `ownership-and-structure` · `correct-cutover` · `numerical-precision` · `derivation-before-implementation` · `staleness-sweep` · `no-silent-except` |
| Equation-critical sources | `pdf-equation-extraction` · `equation-to-code-traceability` · `reference-license-firewall` · `equation-errata-ledger` |
| Verify | `verification-gate` *(validation stages · while working · close-out)* · `numerical-method-validation` · `gradient-validation` · `reference-parity-audit` · `adversarial-result-check` *(envelope · artifacts · systematics lanes)* · `uncertainty-reporting-gate` *(budget · seed ensembles)* · `no-stub-when-done` |
| Inference rigor | `bayesian-inference-gate` *(prior predictive · convergence · posterior predictive · prior sensitivity · model comparison)* |
| Review *(audit written code/figures)* | `scientific-code-reviewer` *(physics · numerics lenses)* · `jax-code-validator` · `code-craft-reviewer` · `benchmark-generator` · `figure-review` *(design · faithfulness · interpretation)* |
| Performance & scale | `performance-measurement` · `jax-performance` |
| Record | `decision-log-and-commits` · `provenance` *(in-code constants · external data)* · `data-io-validator` · `null-result-integrity` · `assumption-ledger` · `no-secrets-in-git` |
| Communicate *(docs & figures)* | `myst-expert` *(syntax · deploy · xref)* · `docs-writing-voice` · `mystmd-plugin-dev` *(interactive figures · plugins)* · `astro-plotting-craft` *(author · audit)* |
| Reproduce & release | `run-reproducibility` *(run record · environment · artifacts · cluster jobs)* · `research-release-checklist` *(release · citation)* |

Each skill's `description` carries a "Don't use when… (→ sibling)" partition and a `## Related` block, so the suite reads as one ordered protocol. `reference-parity-audit` — the late-stage external-validation milestone — loads a domain lens when one exists (`lenses/mesa.md` ships; others are added when a real parity milestone needs them).

The front of the funnel has **two entries**. When the researcher brings their own model or an open theoretical question, `model-development` adopts it provisionally — Explore/Develop stances derive consequences, expose missing closures and inconsistencies with candidate completions, and pick the next informative calculation; Critique is opt-in; the Test stance hands off to the falsification path below only once the model is specified and a claim is at stake. The **Ideate** and **Literature** clusters (v1.4.0) are the other entry, for choosing a direction: `research-ideation` (divergent — generate and triage directions) → `literature-workflow` novelty mode (is it novel?) → `hypothesis-and-test-design` (sharpen one into a falsifiable hypothesis and design the discriminating run) → `minimal-falsifiable-slice` → Build. The **Inference rigor** gate (`bayesian-inference-gate`) checks the *inference itself* for the NumPyro family — prior predictive, sampler convergence (R-hat/ESS/divergences), posterior predictive fit, prior sensitivity, and honest out-of-sample model selection — distinct from the forward-numerics `Verify` cluster. **Performance & scale** covers measure-first profiling and strong/weak scaling (`performance-measurement`) and JAX compile-boundary performance; HPC job records live in `run-reproducibility`. **Reproduce & release** extends reproducibility to the citable public artifact (CITATION.cff/DOI, the figure→release trace).

The **Equation-critical sources** cluster is for papers whose equations become code, tests, or benchmark fixtures. It keeps rendered-PDF verification, implementation traceability, reference-code licensing boundaries, and errata/conflict decisions separate on purpose. The `equation-verifier` agent is the adversarial row checker for promoting digest rows to `verified`.

The **Review** and **Communicate** clusters and several MyST references were consolidated in v1.2.0 from the former `astro-code-review` and `myst` plugins (now retired) — see the Status section. MyST authoring skills ship co-located references (`myst-cheatsheet`, `math-and-gotchas`, `myst-projects-and-workflows`, `voice-fingerprint`, `page-anatomy`) and the shippable `mystmd-plugins/interactive.mjs` directive bundle.

## Hooks (enforcement)

The skills document the discipline; twelve **path-/command-scoped, self-limiting** hooks (plus a skill-activation logger that is silent unless `RWF_HOOK_DEBUG` is set) (`hooks/hooks.json`) enforce it. Each stays inert outside research code (e.g. during course work or quick edits) and **fails open** on any error, so it never blocks legitimate work.

| Hook | Event | Fires on | Action |
|---|---|---|---|
| deletion gate | `PreToolUse(Bash)` | `rm` / `git rm` / `git clean` / `shred` | asks for confirmation before a destructive op |
| no-secrets-in-git | `PreToolUse(Bash)` | `git add`/`commit` that names a credential file (`.env`, `*.pem`, …) or stages a secret signature (AWS/GitHub/Slack/Google token, `PRIVATE KEY` block, `api_key=…`) | asks before a secret enters git history |
| test-integrity | `PreToolUse(Edit/Write)` | edits to `test_*.py` / `tests/**` that loosen a tolerance, drop an `assert`, or add `skip`/`xfail` | asks before a test is weakened to pass |
| no-silent-except | `PreToolUse(Edit/Write)` | new Python that catches an exception and does nothing (bare `except:`, or `except …: pass/…/continue`) | asks before an error is silently swallowed |
| myst-docs-hygiene | `PreToolUse(Edit/Write)` | MyST docs (`docs/**/*.md` in a project with a `myst.yml`, and `myst.yml` itself) with legacy Sphinx-MyST syntax (`{toctree}`/`{eval-rst}`/autodoc/RST), or a page missing the house-minimum `title`+`description` frontmatter | asks before legacy/incomplete MyST docs land |
| provenance | `PreToolUse(Edit/Write)` | uncited numeric literals in constants/calibration files, **or** references to external datasets/checkpoints (data-file URLs, `data/raw/…`) with no source/version/checksum | asks for a source (DOI/arXiv/Zenodo/checksum) |
| evidence-before-done | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | a code/test/result/build claim ("fixed / passing / converged / built") with no fresh command output in the turn, or a tests-pass claim when the turn's last test run reports failures | warns (or, with `RWF_STRICTNESS=standard`, blocks) until the verification command + output are shown |
| no-stub-when-done | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | a completion claim ("implemented / complete / ready") while an edit this turn left a stub in code (`NotImplementedError`, `TODO`/`FIXME`, placeholder body) | warns (or blocks under `standard`) until the stub is finished or the scope is restated |
| inference/precision | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | (R) a posterior estimate with an uncertainty but no R-hat/ESS anywhere in the message or turn output; (P) in a JAX project, an error/drift/residual below ~1e-7 with no `jax_enable_x64` evidence (message, turn, or repo). Numbers labeled exploratory/preliminary are exempt. | warns (or blocks under `standard`) until the diagnostics or x64 evidence are shown, or the number is labeled exploratory |
| install freshness | `SessionStart` | a development install (local directory marketplace) whose skills/hooks/commands differ from the source repo | warns with the reinstall command — the pinned version means `plugin update` never refreshes it |
| stance router (opt-in) | `UserPromptSubmit` | every prompt, only when `RWF_STANCE_ROUTER=1` | adds a short reminder of the Explore/Develop/Critique/Test stances, the assumption-approval rule, and derivation-backed experiments |
| jq sanity check | `SessionStart` | `jq` not on `PATH` | warns that the gates are inactive (they need `jq`) |

> **Hooks load at session start — restart Claude Code after installing or updating the plugin to activate them.** Smoke tests: `bash hooks/tests/run_tests.sh`.

### Configuration

All settings are environment variables (set them in your shell or in `settings.json` under `env`):

| Variable | Default | Effect |
|---|---|---|
| `RWF_STRICTNESS` | `advisory` | `advisory`: the three Stop gates show a warning and let the turn end. `standard`: they block the stop and hand the reason back to the model. |
| `RWF_STANCE_ROUTER` | unset | `1` turns on the per-prompt collaboration reminder. Leave it off if your own global instructions already carry one. |
| `RWF_SUBAGENT_EVIDENCE` | unset | also gate subagents' final claims. |
| `RWF_HOOK_DEBUG` | unset | per-decision log (see below). |

**Prerequisite:** the hooks use [`jq`](https://jqlang.github.io/jq/). If `jq` is not on `PATH` they fail open (no-op) — so install it (`brew install jq`) for the gates to be active.

**Debugging:** the hooks are silent by default. To see when each fires and what it decided (`allow:* / ask:* / block:*`), set `RWF_HOOK_DEBUG=1`; entries append to `$RWF_HOOK_LOG` (default `${TMPDIR:-/tmp}/research-workflow-hooks.log`). Example:

```bash
export RWF_HOOK_DEBUG=1
tail -f "${TMPDIR:-/tmp}/research-workflow-hooks.log"
# 2026-06-15T22:41:48 [evidence] block:claim-without-evidence — All tests pass.
# 2026-06-15T22:41:48 [deletion] ask:destructive — rm -rf x
# 2026-06-15T22:41:49 [skill] invoke:research-workflow:numerical-precision
```

The log also records **skill invocations** (`[skill] invoke:<name>`, via a `PreToolUse(Skill)` hook), so a week of `RWF_HOOK_DEBUG` data shows not just which gates fired but which of the 43 skills actually surface in real work — the missing signal for auditing the advisory layer. (Caveat: this captures skills invoked through the Skill *tool*; guidance the model follows without an explicit invocation is not logged — it's a lower bound.)

## Commands

Six slash commands give deliberate entry points (skills also auto-surface by description); each does more than restate a skill:

| Command | Does |
|---|---|
| `/checkpoint [action]` | Go/no-go before an expensive or irreversible run (`researcher-in-the-loop`, *Checkpoints*). |
| `/review [target]` | Multi-lens scientific code/figure review of a changeset — the deterministic entry point for the **Review** cluster (correctness · numerics · JAX · robustness · craft · figures), producing a severity-tagged report. Beats hoping the review skills auto-surface. |
| `/parity <ref>` | Reference-parity audit vs. an external reference at the validation milestone, loading the matching lens (`mesa`). |
| `/reproduce` | Capture a reproducibility contract — env lock, seeds, precision, input ids, commit. |
| `/equation-digest <source>` | Create or review an equation-critical digest from a PDF/source note, with rendered-PDF verification states, traceability, reference-license firewalling, and errata handling. In installed plugin form, Claude may expose it as `/research-workflow:equation-digest`. |
| `/hooks-debug [status\|tail\|on\|off]` | Inspect/enable the hook decision log (see **Debugging** above; enabling needs a `settings.json` env entry + restart). |


## Agents

| Agent | Does |
|---|---|
| `equation-verifier` | Adversarially checks equation-digest rows against rendered PDFs or trusted publisher sources before rows are promoted to `verified`. |

## Adapting it to your field and group

- **Project instructions win.** A project's `CLAUDE.md` / `AGENTS.md` overrides a skill's defaults: put your canonical code paths, reference codes, cost threshold, and parity targets there.
- **Add a lens or reference, not a skill.** A new reference code gets a `reference-parity-audit/lenses/<code>.md` modeled on `mesa.md`; checked domain facts go in a `references/*.md` next to the skill that uses them, with the date and how each entry was checked.
- **House style is a default.** `docs-writing-voice` and `astro-plotting-craft` encode one group's documentation voice and figure style; override them in project instructions or replace their `references/`.
- **Choose the strictness.** `RWF_STRICTNESS=advisory` (default) suits most users; `standard` turns the Stop gates into hard blocks.

## Installation

This plugin is `research-workflow`; the dev marketplace (in `.claude-plugin/marketplace.json`) is `research-workflow-dev`. Public repo: <https://github.com/drannarosen/research-workflow>.

```bash
git clone https://github.com/drannarosen/research-workflow.git
# then, in Claude Code:
/plugin marketplace add ./research-workflow
/plugin install research-workflow@research-workflow-dev
```

Then **restart Claude Code** (hooks load at session start). The version is single-sourced in `.claude-plugin/plugin.json`; keep `marketplace.json` in sync.

## Using the skills from Codex

The skills are plain `SKILL.md` folders, so Codex can load the same files. Symlink rather than copy, so there is one source and no drift:

```bash
ln -s "$PWD/skills" ~/.agents/skills/research-workflow
```

Codex discovers skills one directory level below a symlink in `~/.agents/skills/`; confirm with `codex debug prompt-input | grep -o 'research-workflow/[a-z-]*/SKILL.md' | sort -u | wc -l` (expect 43). Codex shortens each skill description to roughly its first 80 characters when many skills are installed, so every description here leads with its trigger and its nearest "not this" neighbor. The hooks are Claude Code–only, so add a short note to your `AGENTS.md` asking Codex to apply the Stop-gate checks itself (fresh command output for any fixed/passing claim, no stubs in touched code when claiming completion, R-hat/ESS with posterior summaries, x64 for sub-1e-7 JAX precision).

## Development

CI (`.github/workflows/ci.yml`) runs on every push / PR, on Linux and on macOS with the system bash 3.2: `shellcheck` (Linux), the consistency checks, and the hook smoke tests. Run the same locally before committing:

```bash
bash scripts/checks.sh         # version sync (plugin.json == marketplace.json) + skill/command/agent/hook/lens lint
bash hooks/tests/run_tests.sh  # hook smoke tests
```

The hook suite ends with a **KNOWN GAPS** section: behaviours a hook should have but does not yet, each written as the test it should pass. An open gap prints `GAP` without failing the suite; a gap that starts passing fails it, so the fix promotes that line to a normal `check`.

## Status

Consolidated 2026-05-30 from a former 15-skill `scientific-workflow` plugin: the ownership cluster merged → `ownership-and-structure` + `correct-cutover`; the MESA pair → `reference-parity-audit` + `lenses/mesa.md`; decision + commit → `decision-log-and-commits`; the rest were renamed and de-stellarified into a domain-agnostic numerical-research substrate.

**v1.1.0** added the `gradient-validation` skill (finite-difference grad-checks, NaN/zero-gradient traps) and the first four enforcement hooks, and refined every skill — sharper "Use when…" descriptions with sibling disambiguation, concrete computational-astrophysics worked examples, dedupe-by-pointer cross-references, and explicit hard-vs-adaptable stances.

**v1.1.x** then grew the suite to 32 skills and added an epistemic-integrity set (derivation-before-implementation, plausibility-envelope, ai-self-distrust, null-result-integrity, the inference-robustness trio) plus four more deterministic gates (`no-silent-except`, `no-secrets-in-git`, `no-stub-when-done`, `myst-docs-hygiene`).

**v1.2.0** consolidates this into **one comprehensive research plugin**: the former **`astro-code-review`** plugin (11 of its 12 skills — `reproducibility-auditor` dropped as a duplicate of `reproducible-environment-contract` / `artifact-first-reproducibility`) and the former **`myst`** plugin (5 skills + the `interactive.mjs` directive bundle) were migrated in, adding the **Review** (computational-physics code/figure review) and **Communicate** (MyST docs + figure design/publication) clusters → **48 skills, eight enforcement hooks**. Both source plugins are retired (disabled, marked deprecated). MyST skills were re-scoped to research docs (teaching moved to the `sophie` platform).

**v1.3.0** adds the equation-critical source layer: `pdf-equation-extraction`, `equation-to-code-traceability`, `reference-license-firewall`, `equation-errata-ledger`, the `/equation-digest` command, and the `equation-verifier` agent. This is additive to the research workflow rather than a refactor: ordinary source ingest stays lightweight, while implementation-critical equations now have rendered-PDF verification, traceability, firewall, and errata gates.

**v1.3.1** hardens the plugin after adversarial review: Task delegation no longer counts as verification by itself, completion claims scan final touched code files for stubs, the shipped `interactive.mjs` escapes JSON/JS values safely, CI runs official Claude plugin validation, and `scripts/checks.sh` enforces the skill graph promises.

**v1.4.0** extends the suite from 52 to **65 skills** across four new clusters, completing the research lifecycle end-to-end: a true front-of-funnel (**Ideate** — `research-ideation`, `research-brainstorming`; **Literature** — `prior-art-check`), **Inference rigor** for the Bayesian/NumPyro family (`mcmc-convergence-gate`, `predictive-checks`, `model-selection-discipline`), **Performance & scale** for HPC work (`profiling-discipline`, `scaling-validation`, `jax-performance`, `cluster-run-contract`), and a **Reproduce & release** tail for citable artifacts (`software-citation`, `research-release-checklist`, `data-management-plan`). Additive — no hooks added, no skills renamed; sibling plugins keep their boundaries (manuscripts → `manuscript-workflow`, grants → `grant-writing`).

**v1.4.1** completes the **Literature** cluster deferred in v1.4.0: `reading-notes-discipline` (per-paper claim/evidence/caveat intake) and `related-work-map` (durable cross-paper field map) — 67 skills. The boundary against `manuscript-workflow:lit-scan` (per-manuscript citation completeness) was confirmed clean before building: reading-notes is per-paper *intake*, related-work-map is cross-paper *synthesis you maintain*, prior-art-check is the one-time *novelty gate*, lit-scan is late-stage *citation completeness* in a different plugin.

**v1.5.0** adds the **figure craft & interpretation** layer (70 skills), completing the figure lifecycle from authoring to reading: `astro-plotting-craft` (author publication-grade plots in the house style — the jaxstroviz theme/figure helpers as source of truth, seaborn perceptually-uniform colormaps, CVD-safe color discipline, log/linear and LaTeX-not-unicode rules), `plot-craft-reviewer` (audit existing plot *code* for craft defects — wrong axis scale, unicode-vs-LaTeX, mathtext syntax errors, overlays, off-brand/unsafe colormaps), and `figure-interpretation-guard` (what a finished figure lets you *conclude* — over-reading, visual traps, reproducing/comparing paper figures, AI-misread plots). These sit beside the existing design/faithfulness/publication trio (ADR-0009) without overlap; the house style matches the jaxstroviz package as-is (its themes/architecture are near-SoTA), with the colorblind-safety, color×marker, reproducible-font, and perceptually-uniform-colormap upgrade targets named in `astro-plotting-craft/references/house-style.md`.

**2026-09-16 consolidation** (unreleased; version stays 1.1.0): an adversarial review (`docs/reviews/2026-09-16-adversarial-review.md`) merged overlapping skills into mode- or lane-structured ones — 71 → 59. Figures: `plot-design-inspector` + `plot-faithfulness-inspector` + `figure-interpretation-guard` → `figure-review`; `plot-craft-reviewer` → `astro-plotting-craft` audit mode. Results: `plausibility-envelope` + `systematic-error-hunting` → `adversarial-result-check`. Bayesian: four skills → `bayesian-inference-gate`. Literature: three skills → `literature-workflow`. Performance: `profiling-discipline` + `scaling-validation` → `performance-measurement`. Review: `numerical-methods-auditor` → `scientific-code-reviewer` numerics lens. Release notes above keep the historical names.

Also removed after review (2026-09-16): `ai-self-distrust` (its one rule — the assistant's own output gets no benefit of the doubt — is now a rule in `researcher-in-the-loop`), `testing-strategist` (generic; its invariants→diagnostic-plots plan moved to `numerical-method-validation`), `error-handling-reviewer` (covered by the `no-silent-except` hook and the numerics lens). Moved out per ADR-0010/0011: `publication-figure-validator` → folded into manuscript-workflow's figure-polish protocol; `data-management-plan` → folded into grant-writing's `grant-budget-and-docs`. 59 → 54.

**Second consolidation (2026-09-16, 54 → 43; ADR-0015):** `evidence-first-execution` → `verification-gate`; `seed-and-stochasticity` → `uncertainty-reporting-gate`; `experiment-tracking` + `artifact-first-reproducibility` + `reproducible-environment-contract` + `cluster-run-contract` → `run-reproducibility`; `provenance-of-constants` + `data-provenance` → `provenance`; `software-citation` → `research-release-checklist`; `research-brainstorming` + `discriminating-experiment-design` → `hypothesis-and-test-design`; `high-impact-checkpoint` → `researcher-in-the-loop`; `myst-ci` → `myst-expert`; `interactive-figures` → `mystmd-plugin-dev`.

**Modernization (2026-09-16, unreleased):** every skill was rewritten for current models. Scaffolding aimed at older, error-prone models (hard/adaptable boilerplate, excuse tables, generic anti-patterns) is gone; the technical checks remain. The collaboration contract is now explicit: scientific assumptions are approved by the researcher before they become load-bearing, experiments carry a derived prediction, and record-keeping scales from exploratory to reported to released. The Stop gates warn by default (`RWF_STRICTNESS`), an opt-in stance router was added, checked gravitational N-body facts moved in from the former global `astro-code-dev` skill (`numerical-method-validation/references/astro-nbody.md`, correcting G in pc³ Myr⁻² M☉⁻¹, the PEFRL/Yoshida-4 labels, and the self-interaction mask), and personal paths were removed from the shipped references.
