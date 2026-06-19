---
name: benchmark-generator
description: Use when verifying performance claims, characterizing scaling, comparing implementations, or validating against analytic solutions for performance-critical kernels (integrators, force solvers, renderers). Don't use for small analysis scripts (overkill) or for designing a test plan before code exists (→ testing-strategist).
---

# Benchmark Generator

Generate benchmarking and validation code for scientific-computing kernels. The templates below encode the non-obvious bits — JAX warmup/`block_until_ready`, log-log scaling fits, convergence-order checks — adapt them to the specific function.

## Templates

### Performance Benchmark (Python/NumPy)

```python
import timeit
import numpy as np
import pandas as pd

def benchmark_function(func, sizes, n_runs=5, setup_fn=None):
    """
    Benchmark function across problem sizes.

    Parameters
    ----------
    func : callable
        Function to benchmark.
    sizes : list
        Problem sizes to test.
    n_runs : int
        Timing runs per size.
    setup_fn : callable, optional
        Takes size, returns test input.
    """
    if setup_fn is None:
        setup_fn = lambda n: np.random.randn(n)

    results = []
    for n in sizes:
        data = setup_fn(n)

        # Warm-up
        _ = func(data)

        # Time
        times = timeit.repeat(lambda: func(data), number=1, repeat=n_runs)

        results.append({
            'n': n,
            'mean_time': np.mean(times),
            'std_time': np.std(times),
        })

    return pd.DataFrame(results)

def fit_scaling(results):
    """Fit t = a * n^b, return (a, b)."""
    log_n = np.log10(results['n'])
    log_t = np.log10(results['mean_time'])
    b, log_a = np.polyfit(log_n, log_t, 1)
    return 10**log_a, b
```

### JAX Benchmark (Compile Once!)

```python
import jax
import jax.numpy as jnp
import numpy as np
import timeit

def benchmark_jax_function(func, sizes, n_runs=5):
    """Benchmark JAX function with proper warmup."""

    # Compile ONCE outside the loop
    compiled_func = jax.jit(func)

    results = []
    for n in sizes:
        data = jnp.array(np.random.randn(n))

        # Warm-up (trace + compile for this shape)
        _ = compiled_func(data).block_until_ready()

        # Time with block_until_ready
        times = []
        for _ in range(n_runs):
            start = timeit.default_timer()
            _ = compiled_func(data).block_until_ready()
            times.append(timeit.default_timer() - start)

        results.append({
            'n': n,
            'mean_time': np.mean(times),
            'std_time': np.std(times),
        })

    return pd.DataFrame(results)
```

### Convergence Test

```python
def test_convergence_order(solver, analytic, problem, expected_order=2):
    """Verify numerical method converges at expected order."""
    resolutions = [32, 64, 128, 256]
    errors = []

    exact = analytic(problem)

    for n in resolutions:
        numerical = solver(problem, resolution=n)
        error = np.max(np.abs(numerical - exact))
        errors.append(error)

    # Check convergence rate
    for i in range(len(errors) - 1):
        ratio = errors[i] / errors[i+1]
        expected = 2**expected_order
        assert abs(ratio - expected) < 0.5 * expected, \
            f"Order {np.log2(ratio):.1f}, expected {expected_order}"
```

### Validation Against Analytic Solution

```python
def test_against_analytic():
    """Compare numerical to known analytic solution."""

    def analytic_solution(r):
        # Plummer density profile
        M, a = 1.0, 1.0
        return (3*M)/(4*np.pi*a**3) * (1 + (r/a)**2)**(-2.5)

    r = np.logspace(-2, 2, 100)
    numerical = compute_density(r)
    exact = analytic_solution(r)

    rel_error = np.abs(numerical - exact) / exact
    assert np.max(rel_error) < 1e-6
```

### Scaling Plot Template

```python
import matplotlib.pyplot as plt

def plot_scaling(results, expected_slope=None, title="Scaling Analysis"):
    """Plot benchmark results with optional expected scaling."""
    fig, ax = plt.subplots(figsize=(6, 4))

    ax.errorbar(results['n'], results['mean_time'],
                yerr=results['std_time'], fmt='o-', capsize=3)

    if expected_slope is not None:
        # Reference line
        n = results['n'].values
        t0 = results['mean_time'].iloc[0]
        n0 = n[0]
        ref = t0 * (n / n0) ** expected_slope
        ax.plot(n, ref, '--', label=f'O(n^{expected_slope})', alpha=0.7)
        ax.legend()

    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlabel('Problem size (n)')
    ax.set_ylabel('Time (s)')
    ax.set_title(title)

    # Fit and report actual scaling
    a, b = fit_scaling(results)
    ax.text(0.05, 0.95, f'Measured: O(n^{b:.2f})',
            transform=ax.transAxes, va='top')

    plt.tight_layout()
    return fig
```

## Output Format

When asked to generate benchmarks, provide:

1. **Benchmark code** tailored to the specific function
2. **Expected scaling** (O(n), O(n^2), O(n log n), etc.)
3. **Suggested problem sizes** for meaningful measurements
4. **Interpretation guidance** for results

## Limitations

- Generated benchmarks need customization
- Cannot determine appropriate sizes automatically
- Validation requires known solutions or literature
- Performance depends on hardware

## Related

- `testing-strategist` — design the validation/test plan before benchmark code exists.
- `numerical-method-validation` — prove convergence/order, not just runtime scaling.
- `adversarial-result-check` — stress-test performance or accuracy claims before reporting them.
