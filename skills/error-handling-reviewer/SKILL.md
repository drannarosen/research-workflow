---
name: error-handling-reviewer
description: Use when reviewing code robustness — exception handling, input validation, failure modes, error-message quality — especially before releasing public APIs or after mysterious failures. Don't use for scientific correctness (→ scientific-code-reviewer), JAX mechanics (→ jax-code-validator), or numerical stability (→ numerical-methods-auditor).
---

# Error Handling Reviewer

Review robustness: exception handling, input validation, failure modes, error-message quality. Default to critical issues only; give the full report with suggested fixes on request.

## Review Process

### Exception specificity

**Red flag: Bare except**
```python
# BAD: Catches everything, including KeyboardInterrupt!
try:
    result = risky_operation()
except:
    pass  # Silent failure

# BAD: Too broad
try:
    result = compute(data)
except Exception:
    return None  # Which exception? Why?

# GOOD: Specific exceptions
try:
    result = compute(data)
except ValueError as e:
    logger.warning(f"Invalid input: {e}")
    return default_value
except ZeroDivisionError:
    logger.error("Division by zero in density calculation")
    raise
```

### Input validation at boundaries

Public API functions should validate inputs:

```python
# BAD: No validation, will fail mysteriously later
def integrate(state, dt, t_end):
    # ... 100 lines later, cryptic error

# GOOD: Validate at entry point
def integrate(state, dt, t_end):
    """Integrate system forward in time."""
    if dt <= 0:
        raise ValueError(f"dt must be positive, got {dt}")
    if t_end <= 0:
        raise ValueError(f"t_end must be positive, got {t_end}")
    if state.n_particles == 0:
        raise ValueError("Cannot integrate empty state")
    # Now we know inputs are valid
    ...
```

**Where to validate:**
- Public API boundaries (user-facing functions)
- Data loading (external input)
- Internal functions: trust caller, or use `assert` for invariants

### NaN/Inf handling

Numerical code should handle special values:

```python
# BAD: NaN propagates silently
def compute_energy(pos, vel, masses):
    kinetic = 0.5 * masses @ (vel ** 2).sum(axis=1)
    # If any velocity is NaN, result is NaN, no warning

# GOOD: Check for special values
def compute_energy(pos, vel, masses):
    if jnp.any(jnp.isnan(pos)) or jnp.any(jnp.isnan(vel)):
        raise ValueError("NaN detected in state")
    if jnp.any(jnp.isinf(pos)) or jnp.any(jnp.isinf(vel)):
        raise ValueError("Inf detected in state - possible numerical instability")
    ...

# ALSO GOOD: For JAX, check periodically not every call
def run_simulation(state, t_end, dt, check_interval=100):
    for i, t in enumerate(timesteps):
        state = simulation_step(state, dt)
        if i % check_interval == 0:
            _validate_state(state)  # Catch NaN/Inf early
```

### Convergence and iteration failures

Iterative methods should have clear failure modes:

```python
# BAD: Silent non-convergence
def newton_solve(f, x0, tol=1e-10):
    for i in range(100):
        x = x - f(x) / df(x)
        if abs(f(x)) < tol:
            return x
    return x  # Didn't converge, but returns anyway!

# GOOD: Explicit failure handling
def newton_solve(f, x0, tol=1e-10, max_iter=100):
    for i in range(max_iter):
        fx = f(x)
        if abs(fx) < tol:
            return x, {"converged": True, "iterations": i}
        x = x - fx / df(x)

    # Explicit non-convergence handling
    warnings.warn(f"Newton's method did not converge after {max_iter} iterations")
    return x, {"converged": False, "iterations": max_iter, "residual": abs(f(x))}
```

### Error-message quality

Error messages should help debugging:

```python
# BAD: Useless message
raise ValueError("Invalid input")

# BAD: Technical but unhelpful
raise ValueError(f"Shape mismatch: {a.shape} vs {b.shape}")

# GOOD: Context + what's wrong + what's expected
raise ValueError(
    f"Position array has wrong shape: got {pos.shape}, "
    f"expected ({n_particles}, 3). "
    f"Did you pass velocities instead of positions?"
)
```

### Resource cleanup

Files, connections, and temporary resources should be cleaned up:

```python
# BAD: Resource leak on error
def process_file(path):
    f = open(path)
    data = f.read()
    result = process(data)  # If this raises, file never closed
    f.close()
    return result

# GOOD: Context manager
def process_file(path):
    with open(path) as f:
        data = f.read()
    return process(data)

# GOOD: For complex cleanup
def run_simulation(config):
    temp_dir = create_temp_directory()
    try:
        result = simulate(config, temp_dir)
        return result
    finally:
        cleanup_temp_directory(temp_dir)
```

## Output Format (Quick Mode)

```
## Error Handling Review: [filename]

**Critical:**
- Line 45: Bare `except:` clause
- Line 120: Newton solver returns silently on non-convergence

**Warnings:**
- Line 80: No input validation on public function `integrate()`
- Line 200: NaN not checked after division

**Good:**
- Line 150: Proper context manager for file I/O
- Line 300: Specific exception with helpful message
```

## Limitations

- Cannot verify error handling works at runtime
- Cannot assess exception performance impact
- Some "defensive" code adds overhead -- context matters
