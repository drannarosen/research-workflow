---
name: correct-cutover
description: Use when existing API/control-flow/canonical code encodes scientifically wrong ownership and compatibility-preserving edits (wrappers, aliases, adapters, reporting glue) would keep the wrong path alive — break it cleanly instead. Don't use while still diagnosing whether the structure is wrong (→ ownership-and-structure) or to scope the smallest change (→ minimal-falsifiable-slice).
---

# Correct Cutover

When the owner is wrong, cut it over — do not build new logic on top of a known-wrong scientific path, and do not let scaffolding keep that path alive. Scaffolding (wrappers, aliases, compatibility adapters, "temporary" fallbacks, reporting glue added before the owner fix) is the usual way wrong owners survive.

## Priority

- physics ownership > API stability
- falsifiability > compatibility
- delete stale paths after the replacement is validated
- no transition architecture unless the user explicitly asks for one

**Adaptable:** the cutover mechanics and sequencing. **Hard:** no compatibility scaffolding to keep a scientifically wrong path alive.

## Required pre-edit contract

The wrong owner, new owner, and canonical-vs-legacy lanes after the change come from the **`ownership-and-structure` §3 lane contract** — don't restate them. State only the cutover **delta** before editing:

1. **Code to delete now** (the stale path)
2. **Code allowed to remain temporarily** (and only this)
3. **Exact reason the temporary code cannot affect canonical behavior**

## Rules

1. Break APIs if needed.
2. No compatibility shims in the canonical lane.
3. No silent fallbacks.
4. Prefer deletion or quarantine over preservation — but **validate the replacement BEFORE deleting the stale path** (→ `verification-gate`), so the cutover is reversible until proven correct.
5. If a file is already oversized, put the cutover in a new module.

## Worked example (computational astrophysics)

> "Wrong/new owner + lanes: see the `ownership-and-structure` §3 contract (softening becomes solver-owned). Delta — **delete now:** the hardcoded `EPS = 0.05` constant and its import. **May remain temporarily:** the old `legacy_softening()` fn, only behind the `contrib` namespace for a control run. **Why it can't contaminate canonical:** the canonical IC builder no longer references it; it's reachable only by explicit opt-in. I'll validate the new path (two-body |ΔE/E| test) per `verification-gate` *before* deleting `legacy_softening()`."

## Anti-scaffolding check

Before adding any wrapper/alias/adapter/reporting glue, ask: what wrong owner does it protect, is it actually needed, and what direct cutover removes the need for it? **If the scaffolding exists only to preserve a wrong owner, do not add it.**

## Rationalizations

| Excuse | Reality |
|---|---|
| "I'll keep a thin compatibility wrapper so nothing breaks." | A shim in the canonical lane keeps the wrong owner alive. Break the API instead. |
| "Add a silent fallback to the old path, just in case." | Silent fallbacks contaminate canonical results. Forbidden. |
| "Delete the stale path now and validate after." | Validate the replacement *first* (→ `verification-gate`); deletion is irreversible if it was wrong. |
| "Build the new logic on top of the existing path for now." | Don't build on a known-wrong owner. Cut over, then build. |

## Related

- `ownership-and-structure` — owns the wrong-owner + lane contract (§3) this skill executes against.
- `minimal-falsifiable-slice` — scope the cutover to the smallest provable change.
- `decision-log-and-commits` — land the cutover as its own evidence-backed, single-purpose commit.
- `verification-gate` — prove the replacement is correct *before* deleting the stale path.
