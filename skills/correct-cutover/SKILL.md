---
name: correct-cutover
description: Use when existing API/control-flow/canonical code encodes scientifically wrong ownership and compatibility-preserving edits (wrappers, aliases, adapters, reporting glue) would keep the wrong path alive — break it cleanly instead. Don't use while still diagnosing whether the structure is wrong (→ ownership-and-structure) or to scope the smallest change (→ minimal-falsifiable-slice).
---

# Correct cutover

When the owner is wrong, cut it over. New logic built on a known-wrong scientific path inherits the
error, and scaffolding (wrappers, aliases, compatibility adapters, "temporary" fallbacks, reporting
glue added before the owner fix) is the usual way a wrong owner survives. Breaking a public API or
replacing a canonical lane is a researcher checkpoint, so the cutover plan is approved before the
edit (→ `researcher-in-the-loop`). The mechanics and sequencing adapt to the codebase; keeping a
scientifically wrong path alive through scaffolding does not.

## Priority

- physics ownership > API stability
- falsifiability > compatibility
- delete stale paths after the replacement is validated
- no transition architecture unless the researcher asks for one

## Pre-edit contract

The wrong owner, the new owner, and the canonical-vs-legacy lanes after the change come from the
`ownership-and-structure` §3 lane contract; don't restate them. State only the cutover delta before
editing:

1. **Code to delete now** (the stale path).
2. **Code allowed to remain temporarily** (and only this).
3. **Exact reason the temporary code cannot affect canonical behavior.**

## Rules

1. Break APIs if needed.
2. No compatibility shims in the canonical lane.
3. No silent fallbacks; they contaminate canonical results.
4. Prefer deletion or quarantine over preservation, but validate the replacement before deleting the
   stale path (→ `verification-gate`), so the cutover stays reversible until proven correct.
5. If a file is already oversized, put the cutover in a new module.

## Worked example (computational astrophysics)

> "Wrong/new owner + lanes: see the `ownership-and-structure` §3 contract (softening becomes
> solver-owned). Delta — **delete now:** the hardcoded `EPS = 0.05` constant and its import. **May
> remain temporarily:** the old `legacy_softening()` fn, only behind the `contrib` namespace for a
> control run. **Why it can't contaminate canonical:** the canonical IC builder no longer references
> it; it's reachable only by explicit opt-in. I'll validate the new path (two-body |ΔE/E| test) per
> `verification-gate` *before* deleting `legacy_softening()`."

## Anti-scaffolding check

Before adding any wrapper, alias, adapter, or reporting glue, ask what wrong owner it protects, whether
it is actually needed, and what direct cutover removes the need for it. If it exists only to preserve
a wrong owner, don't add it.

## Related

- `ownership-and-structure` — owns the wrong-owner + lane contract (§3) this skill executes against.
- `minimal-falsifiable-slice` — scope the cutover to the smallest provable change.
- `decision-log-and-commits` — land the cutover as its own evidence-backed, single-purpose commit.
- `verification-gate` — prove the replacement is correct *before* deleting the stale path.
- `staleness-sweep` — the docs and comments that described the old path.
