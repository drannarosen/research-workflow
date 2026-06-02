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

## Required pre-edit contract

State explicitly before editing:

1. Wrong owner · 2. New owner · 3. Canonical path after the change · 4. Legacy path after the change · 5. Code to delete now · 6. Code allowed to remain temporarily · 7. Exact reason the temporary code cannot affect canonical behavior.

## Rules

1. Break APIs if needed.
2. No compatibility shims in the canonical lane.
3. No silent fallbacks.
4. Prefer deletion or quarantine over preservation.
5. If a file is already oversized, put the cutover in a new module.

## Anti-scaffolding check

Before adding any wrapper/alias/adapter/reporting glue, ask: what wrong owner does it protect, is it actually needed, and what direct cutover removes the need for it? **If the scaffolding exists only to preserve a wrong owner, do not add it.**

## Related

- `ownership-and-structure` — confirm the wrong owner + lane contract before cutting over.
- `decision-log-and-commits` — land the cutover as its own evidence-backed, single-purpose commit.
- `verification-gate` — prove the cutover didn't change correct behavior.
