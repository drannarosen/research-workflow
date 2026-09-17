# Lens: <reference code> parity (<domain>)

Instantiation of `reference-parity-audit` for <your code> compared against <reference code, version>.
`mesa.md` is a filled-in example.

## Audit questions (read the reference source at the pinned version)

List the 4–8 questions whose answers decide whether two runs are comparable at all, e.g.:
1. How does the reference construct its initial state?
2. Which solver, timestep control, and tolerances are active?
3. Where does each source term enter, and who owns it?
4. What resolution or remeshing path is active?
5. What stop criteria define the landmark being compared?
6. Which boundary conditions or closures are active?

## Landmarks (pick first, then compare at the matched state)

Physically defined states both codes reach (e.g. a phase onset, a first core collapse, a given
dynamical time), not wall-clock time or step number.

## Observables to compare at each landmark

Scalars and profiles, with units and the tolerance the researcher approved for each.

## Claim rule

Don't call a result "<reference>-parity" unless the landmarks are matched and the bookkeeping of the
quantities above is file-backed against the reference source, not analogized.
