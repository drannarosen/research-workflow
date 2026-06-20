# Skill-efficacy eval — batch 3 (omission-discipline) + unified thesis
*2026-06-19 · v3 targets the 1c "omission-discipline" cluster on Opus (the hard case). 3 skills × RED/GREEN.*

## Results

| Skill | RED (no skill) | GREEN (with skill) | Verdict |
|---|---|---|---|
| `provenance-of-constants` | **cited Kroupa (2001), MNRAS 322, 231** unprompted | cited + structured | RED passed — **scenario too easy** (famous constant; Opus cites famous refs reflexively) |
| `reproducible-environment-contract` | pinned deps + `uv.lock` (internalized) — **but omitted precision/seed/checksum** | lock **+ `capture_env.py`**: float-precision (the silent JAX float32 trap), RNG seeds, input sha256 | **PARTIAL EFFICACY** — on the *non-obvious* sub-discipline |
| `experiment-tracking` | **refused to fabricate** a missing `fit_model` (cwd confound) | wrote full tracking machinery with stubbed seams | **INVALID** — RED produced no script to score |

## Harness lessons (v3 broke in informative ways)
- **cwd confound:** subagents run in the *plugin* repo, explore it, and either refuse ("no `fit_model` here") or anchor to it. Future runs must be **greenfield/isolated** (`isolation: worktree` or explicit "don't read this repo").
- **Agents write files:** RED/GREEN wrote `imf.py`, `pyproject.toml`, `uv.lock`, `scripts/sweep.py`, `runs/` into the repo (cleaned up). **Sandbox future eval agents.**
- **Pre-registered signal set too low:** RED cleared "pin deps," but the *value* was the omitted precision/seed/checksum capture. The signal must target the **non-obvious sub-discipline**, not the generic action.
- **Famous-constant scenario too easy:** the real omission risk is an *obscure* calibration constant, not Kroupa.

## The unified thesis (all 3 batches, ~10 distinct skills)

**A skill changes behavior to the extent it carries non-obvious knowledge the model lacks, or a stance it would not take by default.** Everything else — restatements of internalized rigor — is a no-op even at the Haiku tier.

The three demonstrated efficacy signals are all the same shape:
- **v1 `astro-plotting-craft`** → the house palette / jaxstroviz API (pure local knowledge).
- **v2 `correct-cutover`** → clean-cutover over the compat-shim reflex (counter-stance).
- **v3 `reproducible-environment-contract`** → the JAX float32 trap + seed/checksum capture (the *non-obvious sub-part* of an otherwise-internalized discipline).

And the no-ops are all the same shape: convergence-exists, seed-ensembles, refute-results, GPL-incompatibility, deps-pinning, cite-Kroupa — rigor Opus already performs unprompted.

**Corollary — the unit of value is the non-obvious *nugget*, not the whole skill.** Even a "useful" skill is mostly dead weight wrapped around a small payload: `reproducible-environment-contract`'s value is "record `jax_enable_x64`, seeds, input checksums" — the surrounding "pin your deps" prose is inert. The generic discipline is internalized; the specific trap is not.

## Implications (sharper than the Tier-1/Tier-2 split)
1. **Compress to the nugget.** Most skills could shrink to their non-obvious payload + a one-line pointer. The essays restating internalized rigor are context cost without behavioral return.
2. **Deterministically-checkable nuggets → hooks.** Where a nugget is a checkable invariant (float32 recorded? R-hat in output? secret in diff?), a hook beats advisory prose — it fires exactly when the model *doesn't* do the thing.
3. **The 70-count overstates the value; the value is concentrated** in local knowledge + counter-stances + a handful of non-obvious traps, plus the 8 deterministic hooks. (Reinforces: don't shatter the suite — concentrate it.)
4. **1c is not refuted — it's untested at the nugget level.** The generic part is internalized; the non-obvious parts (precision/seed/checksum, obscure constants) showed the one partial hit. A fair v4 must target the nuggets with obscure inputs, isolated cwd, weaker tiers, and long-context workload.

## Honest status
Sample is ~10 of 70, single-decision, Opus-heavy, with two invalid/too-easy cells this batch. This is a strong, repeatedly-replicated *direction* (efficacy ∝ non-obvious payload), not a per-skill census. The actionable move is to **refactor toward nuggets + hooks**, not to keep accumulating advisory essays.
