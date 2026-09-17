# Gravitational N-body: facts and checks

Domain reference for validating gravitational N-body and star-cluster code. Every entry below was
checked on 2026-09-16, numerically in CGS or against the cited paper. Thresholds are given as
**scalings**, not universal numbers: a fixed tolerance that ignores N, precision, or step size
fails correct code or passes broken code. Anything not listed here is not verified; derive it or
cite it rather than filling it in from memory.

## Constants and unit systems

| Quantity | Value | Note |
|---|---|---|
| G [pc (km/s)² M☉⁻¹] | 4.3009e-3 | the velocity-unit form |
| G [pc³ Myr⁻² M☉⁻¹] | 4.4984e-3 | **not** 4.3009e-3; 1 km/s ≈ 1.0227 pc/Myr |
| G [AU³ yr⁻² M☉⁻¹] | 4π² ≈ 39.478 | exact only with the Gaussian (Kepler) year; with the Julian year 39.477 (4e-5 relative) |
| G [cm³ g⁻¹ s⁻²] | 6.6743e-8 | CODATA 2018 |

Convert from CGS in code (`G * Msun * t_unit**2 / L_unit**3`) instead of hardcoding a derived value,
and state the year definition when an AU/yr system is used.

## Plummer sphere (Plummer 1911)

- ρ(r) = (3M / 4πa³)(1 + r²/a²)^(−5/2); Φ(r) = −GM / √(r² + a²).
- 3D half-mass radius r_h = a / √(2^(2/3) − 1) ≈ 1.3048 a.
- Radius sampling: invert M(<r)/M = r³/(r² + a²)^(3/2) = u → r = a / √(u^(−2/3) − 1)
  (Aarseth, Hénon & Wielen 1974, A&A 37, 183). Velocities by rejection sampling of
  q²(1 − q²)^(7/2) with v = q √2 (1 + r²/a²)^(−1/4) in G = M = a = 1 units.
- **Virial check scales with N.** Sampled 2K/|U| scatters by ~0.08 at N = 100 and ~0.03 at
  N = 1000 (20 seeds each; a scatter of order 1/√N). Judge a sampler by agreement within a few σ of
  1 at its N, or by the mean over seeds, not by a fixed `|Q − 1| < 0.05`.

## Pairwise forces in JAX

- **Self-interaction:** multiplying by `1 − eye(N)` does **not** remove the r = 0 singularity:
  0 × inf is NaN in the forward pass, and the gradient is NaN too. Replace the diagonal *before* the
  division (the "double where"), then zero it:
  ```python
  eye = jnp.eye(N, dtype=bool)
  r = jnp.sqrt(jnp.where(eye, 1.0, r2))      # safe value on the diagonal
  phi = jnp.where(eye, 0.0, -m_i * m_j / r)  # then remove it
  ```
  Checked: the forward value and `jax.grad` are both finite; the multiplicative mask gives NaN in both.
- **Softening consistency:** if forces use a softened kernel, the energy diagnostic must use the
  same softened potential, or |ΔE/E| shows a constant bookkeeping offset that no timestep change
  removes.
- **Two force paths** (a loop and a vectorized path, or two summation orders) agree only to
  round-off accumulated over N terms: ~1e-13 relative at N = 2000 in float64. Use `rtol` of order
  `N · eps`, not 1e-14.
- **Precision:** float32 resolves ~1.2e-7 relative. Any reported drift, residual, or tolerance
  below that needs `jax_enable_x64` (→ `numerical-precision`). Prefer a loud guard at construction
  over mutating `jax.config` on import.
- Physical guards inside `jit` cannot be plain Python `assert`s on traced values; use
  `equinox.error_if` or `jax.experimental.checkify`, or validate inputs before tracing.

## Integrators

| Scheme | Coefficients | Source |
|---|---|---|
| Yoshida 4th order (triple jump of leapfrog) | w₁ = 1/(2 − 2^(1/3)) ≈ 1.35120719, w₀ = −2^(1/3)/(2 − 2^(1/3)) ≈ −1.70241438; steps (w₁, w₀, w₁) | Yoshida 1990, Phys. Lett. A 150, 262 |
| PEFRL (position-extended Forest–Ruth-like) | ξ = 0.1786178958448091, λ = −0.2123418310626054, χ = −0.06626458266981849 | Omelyan, Mryglod & Folk 2002, Comput. Phys. Commun. 146, 188 |

The PEFRL coefficients are often mislabeled "Yoshida-4". They are a different scheme with a
smaller error constant. Checked: the PEFRL coefficients above give a measured global order of 4.000
on the harmonic oscillator.

- **Order check:** for a p-th-order scheme, |E(h) − E(h/2)| / |E(h/2) − E(h/4)| ≈ 2^p (16 for
  4th order), measured in the asymptotic band (→ SKILL.md, *Required statement*).
- **Energy error** of a fixed-step symplectic scheme is bounded and oscillatory with amplitude
  ∝ h^p. Its size depends on h relative to the shortest orbital timescale and on eccentricity, so
  there is no universal drift threshold. Report the maximum |ΔE/E| over the horizon, and compare the
  scaling with h.
- A state-dependent adaptive step breaks symplecticity: bounded error becomes secular drift. Use a
  time-symmetric step or report the drift as such.
- Long differentiable integrations: bound backward-pass memory with `jax.checkpoint` on segments,
  or use an adjoint (e.g. diffrax) where exact reverse-mode through every step isn't needed.

## Tree codes

- Barnes & Hut 1986, Nature 324, 446: open a cell when size/distance ≥ θ; cost O(N log N).
  FMM-style O(N): Dehnen 2002, J. Comput. Phys. 179, 27.
- The force error depends on θ, the multipole order, and the particle distribution. Measure it
  against direct summation on your own distribution at your θ, rather than quoting a generic
  scaling.

## Useful external milestones (for the end-stage validation)

- Cluster dissolution times in tidal fields: Baumgardt & Makino 2003, MNRAS 340, 227
  (T_diss ∝ T_rh^x with x ≈ 0.75 for W₀ = 5 King models).
- Textbooks: Aarseth 2003, *Gravitational N-Body Simulations*; Heggie & Hut 2003, *The
  Gravitational Million-Body Problem*; Hairer, Lubich & Wanner 2006, *Geometric Numerical
  Integration* (2nd ed.).
- Roche-lobe radius (Eggleton 1983, ApJ 268, 368): R_L/a = 0.49 q^(2/3) / (0.6 q^(2/3) +
  ln(1 + q^(1/3))), with q = M₁/M₂ for the lobe around star 1; accurate to ~1% for all q.
