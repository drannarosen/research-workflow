# Lens: MESA parity (stellar evolution)

Concrete instantiation of `reference-parity-audit` for stellax-vs-MESA work.

## Audit questions (read the local MESA source directly)

1. How does MESA construct the starting model family?
2. How does it relax/evolve before the model becomes meaningful?
3. Where does `eps_grav` enter the energy bookkeeping?
4. What remesh path is active during relax/evolve?
5. What stop criteria define the MESA landmark being compared?
6. What surface closure / atmosphere choice is active?

## Landmarks (pick first, then compare stellax at the matched state)

- constructed seed
- post-relax-step landmark
- radiative-core-onset landmark
- accepted handoff landmark

## Observables to compare at each landmark

`R_surf`, `L_surf`, `T_eff`, `T_c`, `rho_c`, and relevant profiles `r(m)`, `T(m)`, `rho(m)`, `L(m)`, `eps_grav(m)`, `eps_nuc(m)`.

Do not call a trajectory MESA-parity unless these landmarks are matched and the bookkeeping (esp. `eps_grav`) is file-backed, not analogized.
