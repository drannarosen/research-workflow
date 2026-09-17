---
name: benchmark-generator
description: Use when verifying performance claims, characterizing scaling, comparing implementations, or validating against analytic solutions for performance-critical kernels (integrators, force solvers, renderers) — this generates the benchmark/validation code. Don't use for small analysis scripts (overkill), planning invariants and diagnostics before code exists (→ numerical-method-validation), the measure-first method or interpreting strong/weak scaling results (→ performance-measurement), or JAX compile-boundary performance (→ jax-performance).
---

# Benchmark Generator

Generate benchmarking and validation code for scientific-computing kernels, tailored to the function
at hand. Timing loops, DataFrames, and log-log plots need no template. The parts below are the ones
that are easy to get wrong: excluding compilation, blocking on async dispatch, fitting the scaling
exponent, and checking convergence order rather than just a small error.

## What to deliver

1. Benchmark code tailored to the function.
2. The expected scaling (O(n), O(n²), O(n log n), ...) or convergence order, derived from the
   algorithm before running. This is the prediction the measurement is compared against.
3. Problem sizes that span the regime of interest (sizes can't be chosen automatically; small sizes
   are dominated by overhead).
4. How to read the result, per `performance-measurement`.

Any pass/fail threshold in generated tests (the order tolerance, the `1e-6` below) is a placeholder
the researcher sets, not a default (→ `researcher-in-the-loop`). Timings depend on hardware; record
it (→ `run-reproducibility`).

## Timing: warm up, then repeat

For NumPy, warm up once per size (caches, lazy imports), then `timeit.repeat(..., number=1,
repeat=n_runs)` and report the spread, not a single run. For JAX, compile once outside the loop, warm
up once per shape (each new shape traces and compiles), and block on async dispatch before stopping
the clock:

```python
import jax, jax.numpy as jnp, numpy as np, pandas as pd, timeit

def benchmark_jax_function(func, sizes, n_runs=5):
    compiled_func = jax.jit(func)                      # compile once, outside the loop
    results = []
    for n in sizes:
        data = jnp.array(np.random.randn(n))
        _ = compiled_func(data).block_until_ready()    # warm-up: trace + compile for this shape
        times = []
        for _ in range(n_runs):
            start = timeit.default_timer()
            _ = compiled_func(data).block_until_ready()  # otherwise you time the launch, not the work
            times.append(timeit.default_timer() - start)
        results.append({'n': n, 'median_time': np.median(times), 'iqr_time': np.subtract(*np.percentile(times, [75, 25]))})
    return pd.DataFrame(results)

def fit_scaling(results):
    """Fit t = a * n^b in log-log space; return (a, b)."""
    b, log_a = np.polyfit(np.log10(results['n']), np.log10(results['median_time']), 1)
    return 10**log_a, b
```

Compare the fitted `b` with the expected exponent, and fit only over sizes past the overhead-dominated
regime. For weak-scaling sweeps, hold work per worker fixed (√2 × N per doubling for O(N²) kernels)
(→ `performance-measurement`).

## Convergence order

A small error at one resolution says nothing about order. Fit the observed order over the
asymptotic levels only (errors above round-off, below saturation) and compare it with the theoretical
order (→ `numerical-method-validation`, *Required statement*). `rel_tol` is the researcher's to set;
~10% is the usual starting proposal.

```python
def test_convergence_order(solver, analytic, problem, expected_order, rel_tol,
                           resolutions=(32, 64, 128, 256), floor=None):
    exact = analytic(problem)
    h = np.array([1.0 / n for n in resolutions])
    errors = np.array([np.max(np.abs(solver(problem, resolution=n) - exact)) for n in resolutions])
    keep = errors > (floor if floor is not None else 100 * np.finfo(errors.dtype).eps)
    assert keep.sum() >= 3, "need >= 3 levels above the round-off floor"
    p_obs = np.polyfit(np.log(h[keep]), np.log(errors[keep]), 1)[0]
    assert abs(p_obs - expected_order) <= rel_tol * expected_order, \
        f"observed order {p_obs:.2f}, expected {expected_order}"
```

## Validation against an analytic solution

Validation needs a known solution or a literature result. Example: the Plummer density profile.

```python
def test_against_analytic():
    def analytic_solution(r):
        M, a = 1.0, 1.0
        return (3*M)/(4*np.pi*a**3) * (1 + (r/a)**2)**(-2.5)

    r = np.logspace(-2, 2, 100)
    rel_error = np.abs(compute_density(r) - analytic_solution(r)) / analytic_solution(r)
    assert np.max(rel_error) < 1e-6
```

## Related

- `numerical-method-validation` — plan invariants and diagnostic plots before benchmark code exists.
- `adversarial-result-check` — stress-test performance or accuracy claims before reporting them.
- `performance-measurement` — the measure-first method and scaling interpretation; this generates the timing and sweep code it reasons about.
- `jax-performance` — fixes the JAX compile-boundary costs a benchmark exposes.
- `run-reproducibility` — record the hardware and configuration each timing ran on.
