---
name: adversarial-result-check
description: Use when you have a result you are about to trust — to red-team it against confirmation bias and the stable-but-wrong failure mode (numerical artifact, latent bug, boundary effect, or a mundane alternative explanation that fits the same data). Produces the strongest attacks plus the cheapest discriminating test for each. Don't use for reviewing CODE (→ scientific-code-reviewer and the Review cluster), the neutral close-out format (→ verification-gate), reporting the result's uncertainty budget (→ uncertainty-reporting-gate), or explaining a convergence/refinement-floor behavior (→ numerical-method-validation).
---

Posture: skeptical-by-default. The goal is to **kill the result**, not to confirm it. A result you wanted to be true, that didn't crash, and that "looks reasonable" is exactly the dangerous case — convergence to a clean wrong answer is silent. Stop and attack before you believe it, cite it, or build on it.

**Hard:** actually running the cheapest discriminating test before trusting a result — an unrun test is an open hole, not a pass. **Adaptable:** which attack lanes you use and in what order.

## Attack the result (run through every lane)

- **Numerical artifact** — could resolution, timestep/tolerance, floor/clip, or accumulated round-off manufacture this signal? Cheapest kill: re-run at 2× resolution / tighter tolerance and check the effect *moves the way physics says, not the way the grid says* (e.g. a "shock" that sharpens forever under refinement is the grid, not the gas).
- **Boundary / initial-condition artifact** — does the signal live near a domain edge, a ghost zone, t≈0 transients, or the seed of the RNG? Kill: shift the boundary out / change the seed; a real effect survives.
- **Latent bug feeding a plausible number** — a wrong unit, sign, index, or stale array that lands in a believable range. Kill: check the number against an order-of-magnitude hand estimate and its dimensions.
- **Mundane alternative** — what non-exciting explanation fits the *same* data (a known scaling, a selection effect, a fit with too many free parameters)? The exciting hypothesis only wins if it beats the boring one on a discriminating prediction.
- **Hostile referee** — what does a competent adversary attack first? Usually the one figure/number load-bearing for the claim. Pre-empt it.
- **Gradient / autodiff** (if the result feeds gradient-based inference/optimization) — the forward value can be right while the gradient is silently wrong, which corrupts every fit built on it. Kills: (1) finite-difference grad-check the loss against `jax.grad` — disagreement beyond ~`1e-5` (float64) means a wrong gradient; (2) `jnp.isnan`/`isinf` on the gradient even where the forward value is finite (a `sqrt`/`log`/`pow` at the boundary back-propagates `nan`); (3) a silent **zero or blocked** gradient from `stop_gradient`, `argmax`/`argsort` (zero a.e.), a `where()` whose dead branch is still differentiated through a singular point, or `clip`/floor **saturation** pinning the output. Full protocol → `gradient-validation`.

## Output

For each surviving attack, give: the failure it posits → the **single cheapest discriminating test** → whether you actually ran it (`ran` / `not run`). **For any `ran` claim, attach the command and its output** — a "ran" with nothing pasted is a `not run`. Rank by `(plausibility × damage-if-true) / cost-to-test`; do the top one or two now. Never report "survived" for a test you only described — an unrun discriminator is an open hole, not a pass.

## Anti-patterns

- Treating "the run completed and the plot looks right" as evidence — that is the failure mode, not a defense.
- Listing attacks you never executed and implying the result passed.
- Attacking only the weak objections you can already beat while dodging the load-bearing one.

## Related
- `verification-gate` — sharpens its "what is not yet proven" into active attacks.
- `discriminating-experiment-design` — design the discriminator *before* the result exists; this skill attacks one already in hand.
- `gradient-validation` — the full protocol for the gradient/autodiff attack lane (finite-difference grad-check, nan/zero/blocked-gradient traps).
- `uncertainty-reporting-gate` — quantify the uncertainty once the result survives attack.
- `reference-parity-audit` — one strong way to attack a claimed result.