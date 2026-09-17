# Adversarial review — full research-workflow plugin (71 skills, hooks, commands, agent)

Date: 2026-09-16 · Mode: AUDIT (read-only) · Method: two independent reviewer agents over all 71 SKILL.md
files (+ references) against a skill-creator rubric (nugget, dead weight, triggering, over-gating,
correctness, explain-why), plus a direct review of hooks/commands/agent. Load-bearing claims were
re-verified by hand (marked **[verified]**). Builds on the 2026-06-19 efficacy evals (efficacy ∝
non-obvious payload) rather than re-arguing them.

## Critical

1. **SIGPIPE false-allow in enforcement hooks [verified].** 18 `printf … | grep -q` pipelines run under
   `set -o pipefail`. When input exceeds the pipe buffer and `grep -q` matches early, printf gets
   SIGPIPE and the pipeline reports failure. Reproduced on `no_secrets_in_git.sh` with a fake AWS key:
   small commit → `ask`; 618 KB staged diff → silent allow, 3/3 runs; same hook without pipefail →
   `ask`. The same pattern can false-allow or false-block `evidence_gate.sh` on long transcripts.
   Hook fixtures were all small, so the suite never exercised it. (Same root cause made
   `scripts/checks.sh` nondeterministic — fixed 2026-09-16.)
2. **Installed plugin is 38 commits stale [verified].** `installed_plugins.json` → cache
   `research-workflow/1.1.0`, commit `a26d706` (2026-06-16), 17 skills. Sessions do not load the
   current suite, hook fixes, or `model-development`. Version stays 1.1.0 (unreleased, by decision), so
   refresh by reinstall.
3. **Technically wrong content in worked examples and tables [verified unless noted].**
   - `gradient-validation`: absolute FD step; at CGS scale (m≈2e33 g) `x+h == x` for all h in the sweep,
     FD gradient = 0, a correct gradient fails. `example.py` says NaN, prints `inf`.
   - `ownership-and-structure:46`: missing-G PE is not a "constant offset"; error is (1−G)·W(t).
   - `minimal-falsifiable-slice:32`: ε=0 vs softened confounds softening with encounter resolution.
   - `seed-and-stochasticity:30`: hard-wires σ/√N; for chaotic dynamics realization spread σ is usually the science.
   - `mcmc-convergence-gate:25`: re-admits retired R-hat 1.05; `model-selection-discipline` lacks Pareto k̂.
   - `numerical-method-validation:15`: shock/discontinuity order depends on norm (L1 ~ p/(p+1) for linear discontinuities).
   - `equation-errata-ledger:34`: lets license decide which formula is correct.
   - `jax-code-validator` (tested, JAX 0.9.2): traced-scalar `if` raises (table says "may work"); shape `if` works (table says FAIL); unregistered `@dataclass` "GOOD" pattern fails under jit.
   - `data-io-validator:20`: "PNG (lossy)" — PNG is lossless.
   - `software-citation:12`: a release cannot contain its own Zenodo *version* DOI.

## Structural

4. **Over-gating (same pathology as premature falsification).** `high-impact-checkpoint` "MUST
   checkpoint and wait" on any sweep (CLAUDE.md says announce >2 min); `experiment-tracking` no result
   acted on without a logged run; `uncertainty-reporting-gate` "never a bare point value";
   `provenance-of-constants` flags every literal but 0/1/2/π; `verification-gate` 8-item close-out for
   any fix; `evidence-first-execution` "one command at a time"; `no_stub_when_done.sh` scans the whole
   touched file, so a pre-existing TODO blocks "done".
5. **Overlap and contradiction.** Six figure skills (+2 external) match "check fig 3 before ApJ";
   `publication-figure-validator` hand-sets 3.5 in/9 pt vs the house theme's 3.35 in/8 pt. One prompt
   ("H₀ 3σ off Planck — real?") matches ≥6 result-checking skills. Seeds are required in five skills.
   Descriptions total ~37 KB (~9k tokens) always in context.
6. **Local assumptions vs "domain-agnostic".** `.claude-work/TASK_X.Y_COMPLETE.md`, `~/Teaching/sophie`,
   `/tmp/teal_synthwave_preview.py`, a repo-state snapshot in `myst-ci`.
7. **Hygiene [verified].** 86 MB `.mypy_cache` in `skills/gradient-validation/`, shipped into the install cache.
8. **June actions not done:** compress-to-nugget, R-hat hook, routing-collision CI.
9. **`model-development` gap.** A consistent closure violating causality/positivity/second law/conservation
   is classed "unconventional, not a defect" unless the researcher declared that limit → sycophancy
   hole. Add a physical-principle-violation category that interrupts Develop.

## Discarded / uncertain reviewer claims
- "Version mismatch 1.6.0" and "CLAUDE.md contradicts model-development" — stale reads (reverted/edited the same day).
- Unverified: MNRAS/ApJ column widths, `.zenodo.json` vs CITATION.cff precedence. (A REBOUND API-name question is moot: the REBOUND lens was removed.)

## Decisions (2026-09-16)
- **A (approved):** fix SIGPIPE in all hooks + >64 KB fixtures; remove/ignore `.mypy_cache`; reinstall.
- **B (approved):** correct all items in #3; add physical-principle category to `model-development`.
- **C (approved):** one scoping rule for record-keeping/verification gates (applies when a number is
  cited, compared across sessions, or shipped; exploration exempt); checkpoint announce-by-default;
  stub hook scans edited lines only; single seed owner.
- **D (merges approved):** figures → `astro-plotting-craft` (author/audit) + `figure-review`
  (design/faithfulness/interpretation modes; supersedes ADR-0009 packaging, keeps its layers);
  result checks → `adversarial-result-check` with lanes (name kept; ADR-0003 partition kept as lane 5); Bayesian → one gate;
  literature → one skill; performance → one skill; physics code review → one skill.
  **Deletions pending approval** (rationale in session): `ai-self-distrust`, `testing-strategist`,
  `error-handling-reviewer`, `publication-figure-validator` (per ADR-0010), `data-management-plan` (→ grant plugin).
- **E (deferred):** description-length/externals lint, R-hat/x64 hooks, skill-creator evals (needs `claude -p` auth).

## Implementation status (2026-09-16)
| Batch | Commit | Outcome |
|---|---|---|
| A | `965ff54` | SIGPIPE fixed in all hooks + `checks.sh`; 10 large-input fixtures (5 RED on old hooks) |
| B | `2eeb698` | Content corrections; JAX claims re-tested in JAX 0.11.1 |
| C | `6c4e0df` | Gates scoped to reported/shipped numbers; stub hook scans edited text only |
| D | `b88cec8` | 71 → 59 by mode/lane merges (ADR-0013) |
| D (removals) | `c87c5d9` | 59 → 54; DMP folded into grant-writing `grant-budget-and-docs` (grant-writing `9295b19`); publication-figure checks folded into manuscript-workflow figure-polish (not under git) |
| Follow-up | `86418b7` | **Validation is staged**: physics-checked during development (supervisor accepts magnitude/physics; no reference-code runs required), externally validated at or near the end. REBOUND lens removed. |
| E | `3c787b0`, `82f35e8` | 1024-char description cap + Related-entry lint; `inference_precision_gate.sh` (ADR-0014) |

Still unverified and deliberately not edited: MNRAS/ApJ column widths, `.zenodo.json` vs CITATION.cff precedence. Known limitation not addressed: Stop gates read a 250-line transcript window rather than the current turn.
