# Research Workflow

Domain-agnostic **research-coding workflow discipline** for computational science (the JAX/Python research family — gravax, stellax, progenax, radax, …), packaged as a Claude Code plugin. The human is the scientist-in-the-loop, PI-level collaborator, and supervisor; the skills enforce evidence-first execution, structural correctness over compatibility, falsifiability, and reproducible artifacts. Domain specifics (e.g. MESA parity) live in thin **lenses**, so the stances stay sharp while the suite stays general.

## Skills (20, by workflow phase)

| Phase | Skill |
|---|---|
| Collaborate | `researcher-in-the-loop` · `high-impact-checkpoint` |
| Scope | `minimal-falsifiable-slice` · `discriminating-experiment-design` |
| Build correctly | `ownership-and-structure` · `correct-cutover` · `numerical-precision` |
| Verify | `evidence-first-execution` · `verification-gate` · `numerical-method-validation` · `gradient-validation` · `reference-parity-audit` · `adversarial-result-check` · `uncertainty-reporting-gate` |
| Record | `decision-log-and-commits` · `provenance-of-constants` · `experiment-tracking` · `data-provenance` |
| Reproduce | `artifact-first-reproducibility` · `reproducible-environment-contract` |

Each skill's `description` carries a "Don't use when… (→ sibling)" partition and a `## Related` block, so the suite reads as one ordered protocol. `reference-parity-audit` loads a domain lens when one exists (`lenses/mesa.md` and `lenses/nbody.md` ship; `lenses/rad-transfer.md` is added on first need).

## Hooks (enforcement)

The skills document the discipline; four **path-scoped, self-limiting** hooks (`hooks/hooks.json`) enforce it. Each stays inert outside research code (e.g. during course work or quick edits) and **fails open** on any error, so it never blocks legitimate work.

| Hook | Event | Fires on | Action |
|---|---|---|---|
| deletion gate | `PreToolUse(Bash)` | `rm` / `git rm` / `git clean` / `shred` | asks for confirmation before a destructive op |
| test-integrity | `PreToolUse(Edit/Write)` | edits to `test_*.py` / `tests/**` that loosen a tolerance, drop an `assert`, or add `skip`/`xfail` | asks before a test is weakened to pass |
| provenance | `PreToolUse(Edit/Write)` | uncited numeric literals in constants/calibration files, **or** references to external datasets/checkpoints (data-file URLs, `data/raw/…`) with no source/version/checksum | asks for a source (DOI/arXiv/Zenodo/checksum) |
| evidence-before-done | `Stop` (+ `SubagentStop` when `RWF_SUBAGENT_EVIDENCE` set) | a code/test/result/build claim ("fixed / passing / converged / built") with no fresh command output in the turn | blocks until the verification command + output are shown |
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
bash hooks/tests/run_tests.sh  # hook smoke tests (30 cases)
```

## Status

Consolidated 2026-05-30 from a former 15-skill `scientific-workflow` plugin: the ownership cluster merged → `ownership-and-structure` + `correct-cutover`; the MESA pair → `reference-parity-audit` + `lenses/mesa.md`; decision + commit → `decision-log-and-commits`; the rest were renamed and de-stellarified into a domain-agnostic numerical-research substrate.

**v1.1.0** adds the `gradient-validation` skill (finite-difference grad-checks, NaN/zero-gradient traps) and the four enforcement hooks above, and refines every skill — sharper "Use when…" descriptions with sibling disambiguation, concrete computational-astrophysics worked examples, dedupe-by-pointer cross-references, and explicit hard-vs-adaptable stances.
