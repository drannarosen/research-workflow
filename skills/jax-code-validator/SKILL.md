---
name: jax-code-validator
description: Use when reviewing JAX-based code for JIT compatibility, autodiff, PRNG handling, and functional-programming requirements — differentiable physics, GPU/TPU deployment. Tuned for Stellax/Gravax/Progenax patterns. Don't use for physics/units correctness (→ scientific-code-reviewer), numerical stability (→ numerical-methods-auditor), or figure/I-O review.
---

# JAX Code Validator

Validate JAX code for JIT, autodiff, and functional-purity requirements. Tuned for Stellax/Gravax/Progenax patterns. Default to a concise issue list; give the full report on request.

## Review Process

### Backend consistency (np vs jnp)

The #1 np-vs-jnp mistake — numpy inside a traced function:

```python
# BAD: numpy inside JAX-traced function
@jax.jit
def bad_function(x):
    return np.sum(x)  # Silent failure or wrong behavior!

# GOOD: jax.numpy throughout
@jax.jit
def good_function(x):
    return jnp.sum(x)
```

**Flag:** Any use of `numpy` (`np.*`) inside functions decorated with `@jax.jit`, used in `jax.grad`, or intended to be JAX-traced.

**Recommend:** Replace with `jax.numpy` (`jnp.*`) or lift to constants outside the function.

### Pure function check

JAX functions should be pure (no side effects):

**Red flags:**
```python
# Global state mutation
global_counter = 0
def bad_function(x):
    global global_counter
    global_counter += 1  # Side effect!
    return x * 2

# In-place mutation
def bad_function(x):
    x[0] = 0  # Mutates input!
    return x

# Print inside JIT (only runs on trace!)
@jax.jit
def bad_function(x):
    print(f"x = {x}")  # Side effect!
    return x * 2
```

**Good pattern:**
```python
def good_function(x, counter):
    return x * 2, counter + 1  # Return new state
```

### State & PyTrees (simulation-code pattern)

For simulation code, prefer functional updates with dataclass states:

```python
# GOOD: Functional state evolution (Gravax/Stellax style)
@dataclass
class State:
    t: Array
    q: Array  # positions
    p: Array  # momenta

@dataclass
class SystemParams:
    masses: Array
    G: float = 1.0

@jax.jit
def step(state: State, params: SystemParams, dt: float) -> State:
    # Pure function, returns NEW state
    ...
    return State(t=state.t + dt, q=new_q, p=new_p)
```

**Red flag:** Methods that mutate attributes (`self.q = ...`) inside code meant to be jitted/differentiated.

### Control flow

**Nuanced guidance:**

| Pattern | In @jit | In grad | Recommendation |
|---------|---------|---------|----------------|
| `if x > 0` (x is scalar traced) | Caution | Caution | May work but subtle tracing |
| `if x.shape[0] > 10` | FAIL | FAIL | Shape-dependent = retrace |
| `jnp.where(cond, a, b)` | PASS | PASS | Always safe |
| `lax.cond(pred, true_fn, false_fn)` | PASS | PASS | For complex branches |
| `lax.fori_loop` | PASS | PASS | For fixed iteration loops |

**Recommend:** For functions intended to be jitted and differentiated, prefer `lax.cond`/`lax.switch`/`jnp.where`. Simple scalar conditionals may work but can lead to subtle tracing behavior.

### Random number handling (PRNG)

```python
# BAD: Key reuse
key = jax.random.PRNGKey(42)
x = jax.random.normal(key, (100,))
y = jax.random.normal(key, (100,))  # x == y!

# BAD: numpy random in JAX
@jax.jit
def bad_function():
    return np.random.rand()  # Not JAX!

# GOOD: Proper key splitting
key = jax.random.PRNGKey(42)
key, subkey = jax.random.split(key)
x = jax.random.normal(subkey, (100,))
key, subkey = jax.random.split(key)
y = jax.random.normal(subkey, (100,))
```

### Static vs dynamic arguments

```python
# BAD: Shape depends on runtime value
@jax.jit
def bad_function(x, n):
    return x[:n]  # Retraces for every different n!

# GOOD: Mark static arguments
from functools import partial

@partial(jax.jit, static_argnums=(1,))
def good_function(x, n):
    return x[:n]  # n is static, compiles once per n value

# ALSO GOOD: Use masks for dynamic selection
@jax.jit
def good_function(x, mask):
    return jnp.where(mask, x, 0.0)  # Fixed shape output
```

### Dtype policy

**For astrophysics simulations:** Default to float64.

```python
# FLAG: Explicit downgrade to float32 in physics code
x = x.astype(jnp.float32)  # Why? Document if intentional.

# GOOD: Explicit float64
x = jnp.array(data, dtype=jnp.float64)

# GOOD: Check JAX config
jax.config.update("jax_enable_x64", True)  # Enable float64
```

### Differentiability check

For code that needs gradients:
- [ ] Are all operations differentiable?
- [ ] Are custom gradients implemented correctly?
- [ ] Are there operations that give zero gradients? (`jnp.round`, `jnp.floor`)

**Recommend test pattern:**
```python
# Verify gradient exists and is finite
grad_fn = jax.grad(your_function)
test_input = jnp.ones(10)
grad_value = grad_fn(test_input)
assert jnp.all(jnp.isfinite(grad_value)), "Gradient has NaN/Inf"

# Compare to finite differences
from jax.test_util import check_grads
check_grads(your_function, (test_input,), order=1)
```

## Output Format (Quick Mode)

```
## JAX Validation: [filename]

**Critical:**
- Line 23: `np.sum` inside @jit -> use `jnp.sum`
- Line 45: PRNG key reused

**Warnings:**
- Line 67: Data-dependent `if` in jitted function
- No `jax_enable_x64` check

**Status:** FAIL (fix np->jnp and key reuse)
```

## Limitations

- Cannot verify actual JIT/grad behavior without running code
- May miss subtle tracing issues
- Custom gradient correctness requires mathematical verification

## Related

- `gradient-validation` — finite-difference and autodiff gradient checks.
- `numerical-precision` — dtype and x64 policy for JAX research code.
- `scientific-code-reviewer` — physics/units correctness outside JAX mechanics.
