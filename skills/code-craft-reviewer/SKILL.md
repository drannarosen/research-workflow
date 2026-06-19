---
name: code-craft-reviewer
description: Use when reviewing code organization, abstraction/DRY, and docs (docstrings, README, guides) for scientific-computing repos — research-code pragmatism, not enterprise patterns. Don't use for physics/units correctness (→ scientific-code-reviewer), JAX mechanics (→ jax-code-validator), or numerical stability (→ numerical-methods-auditor).
---

# Code Craft Reviewer

Review the *craft* of scientific-computing code — structure, abstraction, and documentation — separate from its scientific correctness. Default to key issues only; give the full report with suggested fixes on request.

## Guiding principle: research code ≠ production code

Scientific code is read by domain experts and rewritten constantly for experiments. Optimize for: readable by physicists (not just programmers), easy to modify, clear connection to the equations/paper. It does **not** need enterprise patterns (factories, DI frameworks, deep class hierarchies) and shouldn't be prematurely optimized. Judge every "clean code" suggestion against that bar — flag both over- and under-engineering.

## Architecture

**Abstraction — flag both directions:**
- *Over*: class hierarchies for simple scripts, factories/DI for single implementations, "future-proofing" that will never be used.
- *Under*: 500+ line functions, nesting > 3 deep, the same logic copy-pasted with minor variations (extract a parameterized function).

Prefer simple flat functions; refactor to classes only when backends must be swapped, code is reused across projects, or state genuinely benefits from encapsulation.

**Public API surface:**
- [ ] Public API minimal — implementation details not exposed
- [ ] Helpers private (`_prefixed`); `__all__` defined for public modules
- [ ] Names action-oriented (`compute_orbital_period`, not `orbit`)
- [ ] Parameter order consistent across related functions (e.g. every `*_step(state, dt, force_fn)`)

**Layout (computational-astrophysics convention, e.g. gravax):** physics kernels in dedicated modules; integrators *compose* kernels rather than duplicate physics; state transitions isolated to step functions; I/O separated from computation; tests beside the package.

## Documentation

**Docstring–code consistency (the freshness check that matters most):**
- [ ] Documented parameters/defaults/returns match the actual signature
- [ ] Documented exceptions are actually raised
- [ ] **No docstring describing an old API that no longer exists** — the highest-value catch
- [ ] Public functions/classes have docstrings; complex ones include an example

Style: NumPy docstring format (the model already knows it — flag missing/stale content, don't re-teach the format).

**README — for scientific code specifically, beyond the usual purpose/install/quickstart/deps/license:**
- [ ] Link to the paper/citation if applicable
- [ ] Unit system documented
- [ ] Example outputs shown

**Guides (if present):** user guide = install, getting-started, common use cases, API reference, troubleshooting. Developer guide = architecture overview, how to add a feature, testing conventions, release process. Check internal links resolve and referenced functions/classes still exist.

## Output (quick mode)

```
## Code Craft Review: [target]

**Architecture:**
- Lines 50-120, 200-270: duplicated analysis logic → extract function
- `process_all()` does 5 things → split
- Flat structure appropriate for this script size (not an issue)

**Docs:**
- `integrate_orbit`: parameter descriptions missing
- `sample_imf`: example uses removed API (stale)
- README install references old package name
```

## Limitations

- "Good design" is context-dependent; research code has different standards than production.
- Cannot verify external links or run every example.
- Reviews craft only — scientific correctness is `scientific-code-reviewer`'s job.

## Related

- `scientific-code-reviewer` — physics, units, and scientific correctness.
- `jax-code-validator` — JAX transform, PRNG, JIT, and autodiff mechanics.
- `numerical-methods-auditor` — stability, precision, and numerical failure modes.
