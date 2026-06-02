---
name: reproducible-environment-contract
description: Use when capturing the environment a citable numerical result ran in — locked deps, interpreter, OS/hardware + accelerator, float precision, all RNG seeds, and input-data hashes — before the result is allowed to be cited or compared. Pins the re-instantiable world behind a number (e.g. a gravax energy-drift figure or a stellax track). Don't use for recording the run's command/outputs/manifest (→ artifact-first-reproducibility) or for reviewing someone else's reproducibility setup (→ reproducibility-auditor).
---

Capture the *world* a result ran in so it can be re-instantiated bit-for-bit (or as close as the platform allows). Default stance: **no result is citable until its environment is captured and pinned** — a number without a recorded world is a guess, not a measurement.

## The contract — capture all six before citing
1. **Dependencies** — locked, not ranges. `uv.lock` (or `pip freeze` / exact pinned versions) committed alongside the result, not a `>=` in `pyproject`.
2. **Interpreter** — exact Python version (`python --version`), plus the solver/backend lib version that actually matters (e.g. `jax`, `jaxlib`).
3. **Platform** — OS + CPU/arch, and the **accelerator**: CPU vs GPU/TPU, device model, and CUDA/driver version. Backend changes results.
4. **Precision** — float32 vs float64 and the flag that set it (`jax.config.update("jax_enable_x64", True)`). Silent float32 is a top cause of "irreproducible" drift.
5. **Seeds** — *every* RNG: `numpy` seed, JAX `PRNGKey` value, stdlib `random` seed. An unrecorded seed makes a stochastic result uncitable.
6. **Inputs** — a hash (sha256) or content-version of every input dataset / initial-condition file. A path is not a pin; the file behind it can change.

## Rules
- Pin **before** you cite or compare, not after the figure looks good — a retroactively guessed environment is fabrication.
- Prefer machine-captured over hand-typed: emit the six fields programmatically (a `env.json` / lockfile) so they can't drift from reality.
- Note what you *can't* pin (nondeterministic GPU reductions, atomics) explicitly rather than implying bit-exactness you don't have.
- Cross-platform numbers need the contract on **each** platform, not one.

## Anti-patterns
- "It works on my machine" with no captured interpreter/accelerator/precision.
- A committed result whose seeds or input hashes live only in shell history.
- Pinning deps but not precision or accelerator — the three travel together for numerical results.

## Related
- `artifact-first-reproducibility` — records what ran; this pins the world it ran in.
- `reproducibility-auditor` (review plugin) — audits an existing repro setup.
- `verification-gate` — a citable close-out should reference the pinned environment.