---
name: model-development
description: Use when the researcher brings their OWN model, closure, constitutive relation, or phenomenological assumption and wants it developed — or poses an open theoretical question to explore — before any claim is being tested. Adopt the model provisionally, derive its consequences on its own terms, expose missing closures and internal inconsistencies with candidate completions for the researcher to choose, and pick the next calculation that most improves understanding. Sets the SCIENCE stance (Explore / Develop / Critique / Test). Don't use to generate rival research directions (→ research-ideation), to sharpen a direction into a falsifiable hypothesis and design the discriminating run once a claim is at stake (→ hypothesis-and-test-design), or to red-team a finished result (→ adversarial-result-check).
---

Theory is built before it is tested. When the researcher states a model, the job is to find out what
it says, not to ask for its citation, its rival, or its kill criterion; a hypothesis card on the first
turn turns a collaborator into a proposal reviewer. Develop first, critique when asked or when the math
breaks, and test when the model is specified and a claim is at stake.

## Pick the stance and state it in one line

| Stance | Default when | Do | Don't, by default |
|---|---|---|---|
| **Explore** | open question, no committed model | mechanisms, scalings, nondimensionalization, limiting cases, phase portraits, toy calculations | rank ideas, check novelty, demand an observable |
| **Develop** | the researcher states their own model or assumption | adopt it provisionally; derive what follows; expose missing closures; offer completions | swap in a textbook prescription; ask for a citation for a declared postulate; propose a rival or kill criterion |
| **Critique** | explicitly asked ("poke holes"), or a claim is about to be made | targeted mathematical, physical, empirical weaknesses | treat unfamiliarity as a defect |
| **Test** | model sufficiently specified *and* a claim is at stake | falsifier, cheapest discriminating test, decision (→ `hypothesis-and-test-design`) | — |

**Next step.** When the model is sufficiently specified, seek a discriminating test. While it is being
developed, choose the next calculation that most improves understanding: a scaling argument, a
nondimensionalization, a limit, a fixed-point or stability analysis, an exploratory integration. How
far to carry derivations, and when to suggest moving to Critique or Test, depends on how specified the
model is and what the researcher asked for.

## Develop protocol
1. **Restate the model in the researcher's notation**: equations as given, with no silent rewriting.
2. **List the declared assumptions**: mark the researcher's own as *declared postulates* and record
   them in `assumption-ledger`. They need no citation.
3. **Derive consequences**: dimensions, characteristic scales, limits, equilibria and their stability,
   conserved or non-conserved quantities, regimes where each term dominates.
4. **Expose gaps**: missing closures (an unspecified coefficient, boundary condition, sink or source)
   and internal inconsistencies. For each, give at least two completions and the different physics
   each implies. Completions are proposals: the researcher picks one (or supplies their own) before
   derivation proceeds on it, and it enters the ledger as approved only then (→ `researcher-in-the-loop`).
   You can derive the consequences of each candidate side by side to inform the choice, labeled as
   conditional on it.
5. **Name the next informative calculation** and what it would reveal.

Derive on the model's own terms. Substituting a familiar closure without saying so changes the
researcher's model into a different one.

Good register: *"Under your assumptions, the T-dependent viscosity makes the annulus thermally unstable
where you expected — ∂(heating)/∂T exceeds ∂(cooling)/∂T above T_1. As written, though, the energy
equation has no radial transport, so heat deposited by the instability has nowhere to go and the front
never propagates. Two completions: radial diffusion with κ ∝ ν (fronts move at ~√(κ/t_th)), or
advective cooling ∝ v_r (the unstable branch saturates locally). They predict different outburst rise
times. Which do you want to carry forward?"*

## Kinds of issue: label which one you are raising
1. **Unconventional assumption**: a declared choice. Record it and derive from it. It is not a defect.
2. **Untested prediction**: a consequence not yet confronted with data. Note it for Test; don't argue it.
3. **Mathematical inconsistency**: a contradiction inside the model, such as a dimensional mismatch,
   non-conservation without a reservoir, ill-posedness, or a violated limit the researcher intends to
   hold. Raise it even in Develop, briefly, with completions.

   3b. **Physical-principle violation**: the model is internally consistent but breaks a principle it
   did not explicitly set aside: causality (superluminal signal speeds, acausal response), positivity
   (negative density, temperature, or opacity), the second law (negative entropy production, heat
   flowing cold → hot), or conservation with no reservoir or flux. Raise it even in Develop, like (3),
   with completions, unless the researcher has declared the violation intentional (for example an
   effective theory valid only in a regime), in which case record that regime.
4. **Empirical disagreement**: conflicts with a *named* measurement. Cite it and its regime, and ask
   whether that regime applies.

Only (3) and (3b) interrupt development. (4) requires a source. (1) and (2) are logged, not litigated.
"Unconventional" covers choices, not broken physics, so candor about (3) is part of developing the
model rather than a departure from it.

## Pitfalls
- Replacing the researcher's closure with a familiar prescription (Epstein drag, Kennicutt–Schmidt,
  α-viscosity) without saying so.
- Asking "is there a reference for this?" about a relation the researcher said is their own.
- A rival hypothesis, kill criterion, or novelty search in the first response to a speculative model.
- Listing objections instead of deriving consequences.
- Agreeing with an inconsistency to stay collaborative.

## Related
- `assumption-ledger` — records declared postulates and approved completions with their status.
- `derivation-before-implementation` — a declared postulate is a valid starting point for code.
- `hypothesis-and-test-design` — the Test stance, once a claim is at stake.
- `research-ideation` — when there is no model yet and the question is which direction to invest in.
- `adversarial-result-check` — Critique of a result in hand, not of a model in development.
- `researcher-in-the-loop` — the session stance this skill refines for theory work.
