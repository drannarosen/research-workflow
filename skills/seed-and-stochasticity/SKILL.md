---
name: seed-and-stochasticity
description: Use when a result depends on randomness — random seeds, stochastic initial conditions, Monte Carlo draws, random-batch (SGD) training, bootstrap — gate that you never trust a single lucky draw: seed deliberately, run an ensemble, and judge the result by its variation across seeds, separating stochastic noise from real signal. Don't use for pinning a seed so a run reproduces bit-for-bit (→ reproducible-environment-contract), turning the spread into a reported value ± σ (→ uncertainty-reporting-gate), or preserving a failed/negative run (→ null-result-integrity).
---

A result from one seed is one sample of a distribution, not the answer. When randomness enters — seeds, stochastic ICs, Monte Carlo draws, SGD batches, bootstrap — a single run tells you almost nothing about whether an effect is real or a fluctuation. Seed deliberately so runs are attributable and repeatable, then run an ensemble and judge the result by its distribution across seeds, not by the one draw you happened to see.

## Discipline
- **Seed deliberately, record it** → set and log the seed (→ experiment-tracking) so a run is repeatable and attributable; an unseeded stochastic run is unrecoverable.
- **Run an ensemble, not a run** → repeat across N seeds before believing an effect; one seed is an anecdote.
- **Separate noise from signal** → is the effect larger than the seed-to-seed scatter? A difference inside the stochastic spread is not a result (pairs with `uncertainty-reporting-gate` for the `σ/√N` bar).
- **Never cherry-pick the seed** → reporting the seed that "worked" among many that didn't is the stochastic form of p-hacking; record them all (→ null-result-integrity).
- **Watch hidden nondeterminism** → GPU atomics, parallel reductions, hash ordering, async scheduling are randomness you didn't seed. Know which results are bit-reproducible and which only reproducible *in distribution*.

## Anti-patterns
- "It works" from a single seed, with no idea of the seed-to-seed variance.
- An unseeded run whose result can never be reproduced or attributed.
- Re-rolling the seed until the metric clears threshold, then reporting that run.
- Claiming a difference between two stochastic results without checking it against their spread.
- Assuming a fixed seed makes results deterministic when GPU/parallel nondeterminism still moves them.

## Hard vs adaptable
- **Hard rule:** a result that depends on randomness is judged across an ensemble of seeds, never a single draw, and the seed is recorded. One lucky seed is not evidence.
- **Adaptable:** ensemble size and which randomness to control — scale to the stochastic spread and the claim's weight. What must survive: *a distribution over draws, not a hand-picked draw.*

This is the *methodology* of stochastic experiments. Pinning one seed for bit-exact reproduction is `reproducible-environment-contract`; turning the ensemble spread into a reported ± is `uncertainty-reporting-gate`.

## Related
- `reproducible-environment-contract` — pins the seed for bit-exact repro; this requires *varying* it to gauge robustness.
- `uncertainty-reporting-gate` — the seed-to-seed spread becomes the statistical error bar (`σ/√N`).
- `experiment-tracking` — every seeded run is logged with its seed.
- `null-result-integrity` — record the seeds that didn't work; don't cherry-pick the one that did.
