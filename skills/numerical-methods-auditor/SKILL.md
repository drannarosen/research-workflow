---
name: numerical-methods-auditor
description: Use when reviewing numerical algorithms (ODE solvers, root finders, optimizers), floating-point stability, precision, or iterative-method convergence — catastrophic cancellation, overflow, symplectic/structure-preserving integrators. Don't use for physics/units correctness (→ scientific-code-reviewer), JAX-tracing mechanics (→ jax-code-validator), or for validating your OWN method's convergence/conservation during development (→ numerical-method-validation).
---

# Numerical Methods Auditor

Identify numerical stability, precision, and convergence problems in scientific-computing code. Default to a concise issue list; give the full report on request.

## Review Process

### Catastrophic-cancellation scan

Look for subtraction of similar-magnitude quantities:

**Patterns to flag:**
```python
delta = a - b           # If a ~ b, precision lost
1 - cos(small_angle)    # Use 2*sin^2(theta/2) instead
sqrt(a**2 + b**2) - a   # For a >> b, loses precision
exp(x) - 1              # Use expm1(x) for small x
log(1 + x)              # Use log1p(x) for small x
```

### Overflow/underflow scan

**Patterns to flag:**
```python
exp(large_number)       # Overflows for x > ~709
factorial(large_n)      # Overflows for n > 170
a ** large_power        # Can overflow
very_small ** fraction  # Can underflow to 0
```

**Recommend:** Log-space calculations where possible.

### Iterative-method checks

For any loop that approximates a solution:
- [ ] Is there a convergence tolerance?
- [ ] Is there a maximum iteration limit?
- [ ] Is convergence actually checked and reported?
- [ ] What happens if it doesn't converge? (Silent failure = FAIL)

### Tolerance sanity check

**Flag:** Hard-coded tolerances without justification

```python
# Suspicious
rtol = 1e-12  # Why this value? Is it needed? What's the cost?

# Better
rtol = 1e-6   # Justified by: [physical timescale / required precision]
              # Verified by: convergence test showing this is sufficient
```

**Recommend:**
- Justify tolerance choices
- Verify via convergence/cost analysis that tight tolerances are actually needed
- Don't assume "tiny = good"

### Matrix-operation stability

For linear algebra operations:
- [ ] Is the matrix well-conditioned?
- [ ] Is there a condition number check for ill-posed problems?
- [ ] Are singular/near-singular cases handled?
- [ ] Is the appropriate decomposition used?

### Symplectic / structure-preserving methods

**For Hamiltonian dynamics (N-body, orbital mechanics):**

| Check | Why It Matters |
|-------|----------------|
| Is the integrator symplectic when claimed? | Long-term phase-space structure |
| Is it time-reversible when claimed? | Energy drift behavior |
| Are close encounters regularized? | Avoids integration blowup |
| Are there long-term energy drift tests? | Not just short-term error |

**Flag:** Mixing symplectic methods with adaptive timesteps without appropriate care.

**Recommend:** Tests that measure long-term energy drift and phase-space structure, not just short-term error norms.

### Stability analysis (ODE/PDE)

For time-stepping methods:
- [ ] Is the timestep appropriate for the method?
- [ ] CFL condition satisfied (for explicit methods)?
- [ ] Stiffness considered (implicit methods for stiff problems)?

### Precision choice

- [ ] Is float32 vs float64 intentional?
- [ ] Are there operations that need higher precision?
- [ ] Are comparisons with tolerance, not exact equality?

**For astrophysics:** Default to float64. Flag explicit float32 in core physics.

## Pedagogical Code Exception

Some "numerically fragile" patterns may be acceptable in teaching examples (e.g., naive Euler integrator). Treat warnings as advisory unless code is tagged as production/research.

## Output Format (Quick Mode)

```
## Numerical Audit: [filename]

**Issues:**
- Line 42: `a - b` where a ~ b possible (cancellation)
- Line 87: rtol=1e-12 without justification
- No convergence check in Newton iteration

**Recommendations:**
1. Use numerically stable alternative for line 42
2. Add convergence test to justify tolerance
3. Return convergence status from solver
```

## Limitations

- Cannot determine actual numerical behavior without running code
- Stability analysis is pattern-based, not rigorous
- May miss domain-specific numerical issues
- Cannot assess whether tolerances are appropriate without context
