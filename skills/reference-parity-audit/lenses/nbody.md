# Lens: REBOUND parity (N-body dynamics)

Concrete instantiation of `reference-parity-audit` for gravax-vs-REBOUND work.

> **Stub.** This captures the skeleton so a parity run isn't started cold; flesh out the specifics (exact REBOUND module paths, `WHFast`/`IAS15` settings, version-specific defaults) on the first real gravax–REBOUND comparison.

## Pin the reference first

Record REBOUND **version** (release tag or commit), the **integrator** (`IAS15`, `WHFast`, `mercurius`, …) and its settings (`dt`, `epsilon`/tolerance, safe-mode, symplectic correctors), the **gravity** routine (`basic`, `compensated`, tree `opening_angle2`), and the **units/`G`** convention. REBOUND defaults shift between versions — an unpinned build makes "parity" unfalsifiable.

## Audit questions (read the local REBOUND source/docs directly)

1. How are initial conditions built (`add()` order, `move_to_com()`, Jacobi vs barycentric)?
2. What integrator + timestep / tolerance is active, and is it adaptive (`IAS15`) or fixed-step symplectic (`WHFast`)?
3. How is softening / close-encounter handling configured (`softening`, `mercurius` switchover radius)?
4. Where does the energy/angular-momentum bookkeeping live (`calculate_energy()`, and does it include the softened potential)?
5. What stop criterion / output cadence defines the landmark being compared (integration time, number of orbits, encounter)?
6. What `G` / unit convention is set, and does it match the gravax `UnitSystem`?

## Landmarks (pick first, then compare gravax at the matched state)

- constructed IC (post-`move_to_com`)
- after N full orbits of the reference body (matched orbital phase, **not** matched pseudo-time)
- a defined close-encounter / pericenter passage
- end-of-integration handoff state

## Observables to compare at each landmark

Total energy `E` and relative drift `|ΔE/E|`, angular momentum `L`, and per-orbit elements `a`, `e`, `i`, plus orbital phase. State a per-observable tolerance anchored to REBOUND's documented accuracy (e.g. `IAS15` machine-precision energy) **before** comparing.

Do not call a trajectory REBOUND-parity unless the landmarks are phase-matched, the energy bookkeeping (softened vs unsoftened) is file-backed, and the version/integrator/units are pinned — not analogized.
