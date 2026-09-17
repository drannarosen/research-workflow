"""Worked example for the `gradient-validation` skill.

Two things demonstrated, both runnable (`python example.py`):

  1. A reusable finite-difference grad-check harness with an h-sweep.
  2. The real `sqrt(max(x, 0))` NaN-gradient bug (King-model K-function class)
     and the double-`where` / safe-primitive fix that cures it.

JAX-native; float64 enabled (float32 noise swamps a 1e-5 grad-check).
"""

import jax
import jax.numpy as jnp

jax.config.update("jax_enable_x64", True)


# --- 1. Finite-difference grad-check ----------------------------------------
def grad_check(f, x, h_rels=(1e-4, 1e-5, 1e-6, 1e-7, 1e-8), x_scale=1.0):
    """Return (best relative error, best h) of jax.grad(f) vs central FD at x.

    Sweeps h because the accurate window is bounded below by round-off and
    above by truncation error -- a single h can falsely fail.

    The step is RELATIVE to |x|: an absolute h on a CGS-scale input
    (m ~ 2e33 g) is below float64 resolution, x + h == x, the FD gradient is
    exactly 0, and a correct gradient falsely fails.
    """
    g_ad = jax.grad(f)(x)
    best = (jnp.inf, None)
    for h_rel in h_rels:
        h = h_rel * jnp.maximum(jnp.abs(x), x_scale)
        g_fd = (f(x + h) - f(x - h)) / (2.0 * h)
        rel = jnp.abs(g_ad - g_fd) / (jnp.abs(g_ad) + jnp.abs(g_fd) + 1e-30)
        if rel < best[0]:
            best = (float(rel), float(h))
    return best


# --- 2. The NaN-gradient trap and its fix -----------------------------------
def k_buggy(x):
    """sqrt(max(x, 0)): forward-finite at 0, but grad is non-finite there (inf; nan once multiplied by 0)."""
    return jnp.sqrt(jnp.maximum(x, 0.0))


def k_safe(x):
    """Double-`where`: clamp BEFORE sqrt, select the result AFTER.

    A single where(x>0, sqrt(x), 0.0) is not enough -- sqrt(x) is still
    evaluated and differentiated at x=0, so 0 * inf = nan reaches the cotangent. Clamp first.
    """
    safe_x = jnp.where(x > 0.0, x, 1.0)          # never feed 0 to sqrt
    return jnp.where(x > 0.0, jnp.sqrt(safe_x), 0.0)  # select after


if __name__ == "__main__":
    # Grad-check a benign function away from any kink: should pass at ~1e-5.
    f = lambda x: jnp.sin(x) * jnp.exp(-0.5 * x**2)
    rel, h = grad_check(f, jnp.array(0.7))
    print(f"benign f: best rel-err = {rel:.2e} at h = {h:.0e}  -> {'PASS' if rel < 1e-5 else 'FAIL'}")

    # CGS-scale input: a relative step works; an absolute step would give g_fd = 0.
    G = 6.674e-8  # cm^3 g^-1 s^-2, CODATA 2018
    phi = lambda m: G * m / 1e22  # potential-like quantity at r = 1e22 cm
    m_sun = jnp.array(1.989e33)  # g, IAU 2015 nominal solar mass
    rel_cgs, h_cgs = grad_check(phi, m_sun)
    abs_fd = (phi(m_sun + 1e-6) - phi(m_sun - 1e-6)) / 2e-6
    print(f"CGS m=1.989e33 g: relative-h rel-err = {rel_cgs:.2e} -> {'PASS' if rel_cgs < 1e-5 else 'FAIL'};"
          f"  absolute h=1e-6 gives g_fd = {float(abs_fd)} (grad is {float(jax.grad(phi)(m_sun)):.3e})")

    # The trap: forward values agree, gradients do NOT.
    x0 = jnp.array(0.0)
    print(f"\nk_buggy(0) = {k_buggy(x0):.3f}   grad = {jax.grad(k_buggy)(x0)}")  # inf (non-finite)
    print(f"k_safe(0)  = {k_safe(x0):.3f}   grad = {jax.grad(k_safe)(x0)}")     # 0.0

    print(f"\nbuggy grad finite at 0? {bool(jnp.isfinite(jax.grad(k_buggy)(x0)))}")
    print(f"safe  grad finite at 0? {bool(jnp.isfinite(jax.grad(k_safe)(x0)))}")

    # Both forms must still agree with FD away from the edge (the fix is not
    # allowed to change correct interior gradients).
    rel_safe, h_safe = grad_check(k_safe, jnp.array(2.0))
    print(f"\nk_safe interior grad-check (x=2): rel-err = {rel_safe:.2e} -> "
          f"{'PASS' if rel_safe < 1e-5 else 'FAIL'}")
