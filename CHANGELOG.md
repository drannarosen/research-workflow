# Changelog

All notable changes to the **research-workflow** plugin are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/). The plugin version is single-sourced in
`.claude-plugin/plugin.json` (keep `marketplace.json` in sync).

## [Unreleased]

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
- **Skills (3, → 20 total):** `experiment-tracking` and `data-provenance` (Record),
  `numerical-precision` (Build correctly).
- **Slash commands:** `/checkpoint`, `/parity`, `/reproduce`, `/hooks-debug`.
- README: `jq` prerequisite, hook-debugging guide, Commands section. Hook smoke tests expanded to 28.

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
