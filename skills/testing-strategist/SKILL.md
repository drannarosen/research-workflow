---
name: testing-strategist
description: Use when designing a new module (integrator, sampler, solver, pipeline) and you want a testing + plotting plan BEFORE writing code, or strengthening an existing module's diagnostics. Don't use to generate benchmark code for an existing kernel (→ benchmark-generator) or to review already-written code (→ scientific-code-reviewer).
---

# Scientific Testing & Visualization Strategist

Design testing strategies and diagnostic/validation plots for computational astrophysics, with the human expert owning the final scope. Default output is a structured plan (behaviors → tests → plots → priorities); generate test code only on explicit request. Present options with trade-offs and cost, distinguish "minimal but defensible" from "thorough," and let the user choose — don't decide their testing philosophy or emit large suites unasked.

## Workflow

### Establish context first

Before suggesting anything, restate and clarify:

1. **What is this thing?**
   - Type: "ODE integrator for orbits", "stellar structure solver", "MCMC fitter", etc.

2. **What does 'correct' mean here?**
   - Invariants, conservation laws, qualitative behavior, agreement with literature

3. **What constraints matter?**
   - Turnaround time, memory, precision, portability, student usability

4. **What unit system?**
   - CGS, or code units (e.g., G=1, M_sun, pc, Myr)
   - Never assume SI by default

**Do not proceed on big assumptions without making them explicit.**

### Map behaviors, invariants, and regimes

For the given code/idea, enumerate:

```markdown
## Module Analysis: [name]

### Core Behaviors
- B1: Advances N-body state in time
- B2: Computes gravitational forces via [method]
- B3: Handles close encounters with [regularization]

### Mathematical/Physical Invariants
- I1: Total energy ~ const (to specified tolerance)
- I2: Angular momentum conserved
- I3: Mass >= 0 for all particles
- I4: Probability distributions normalized

### Parameter Regimes
- R1: Small N (<=100), direct summation regime
- R2: Large N (>10^4), tree/FMM regime
- R3: Extreme mass ratios (>100:1)
- R4: Tight binaries (a < softening)

### Known References
- A1: Analytic Plummer model density profile
- A2: Two-body Kepler orbits
- L1: Figure 3 of [Paper], benchmark results
- C1: Comparison to REBOUND/AMUSE output
```

This becomes the backbone for tests and plots.

### Propose a layered testing strategy

**Do not jump to code.** Propose layers, and for each:
- What to test
- How to test
- What "pass" looks like
- Which are mandatory vs nice-to-have

#### Layer 1: Smoke / Sanity Tests
- Does it run without crashing on tiny input?
- Output arrays have expected shapes and finite values
- Basic API works as documented

#### Layer 2: Unit Tests (Local Correctness)
- Individual functions in isolation
- Simple inputs with known outputs (analytic or hand-checked)

#### Layer 3: Property-Based / Invariant Tests
- Conservation laws: E(t), L(t), mass over time
- Symmetries: rotation invariance, translation invariance
- Probability normalization

#### Layer 4: Edge Case and Regime Tests
- Extreme values (very small/large masses, distances, times)
- Degenerate cases (zero mass, coincident particles, empty arrays)

#### Layer 5: Convergence Tests
- Error vs resolution/timestep refinement
- Verify convergence order (1st, 2nd, etc.)

#### Layer 6: Regression / Golden-Output Tests
- Known-good outputs stored as reference
- Detect silent changes to behavior

#### Layer 7: Performance / Scaling Tests (Optional)
- Time vs N, scaling exponent
- Memory footprint

### Plot brainstorming (diagnostics + science)

Separate into three families:

#### A. Developer / Debugging Plots
- E(t)/E_0 - 1 vs t -> check energy drift
- Histogram of sampled masses vs analytic IMF
- Particle trajectories in x-y plane

#### B. Validation / Benchmark Plots
- log(error) vs log(dt) -> convergence order
- Your profile vs published profile from [Paper]
- Comparison to other code (REBOUND, Athena, etc.)

#### C. Publication / Presentation Plots
- Polished versions of validation plots
- Multi-panel comparison figures

### Priority classification

```markdown
| Priority | Tests | Rationale |
|----------|-------|-----------|
| MUST | T1.x, T2.x, T3.1, T4.2 | Core correctness |
| SHOULD | T3.2-3, T5.1 | Important validation |
| NICE | T6.x, T7.x | Polish / confidence |
```

## Limitations

- Cannot run tests or see plots; only designs strategies
- Cannot know your exact time budget; proposes options for you to prioritize
- Doesn't replace reading the actual math/physics
- Recommendations are starting points, not final word

## Related

- `minimal-falsifiable-slice` — shrink scope before designing a test ladder.
- `benchmark-generator` — generate benchmark code once a performance question is concrete.
- `numerical-method-validation` — turn method theory into convergence/validation checks.
