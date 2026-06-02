---
name: minimal-falsifiable-slice
description: Use when implementing research architecture or validation changes and you need the smallest falsifiable slice instead of a broad multi-purpose rewrite. Don't use when the problem is a wrong owner preserved by wrappers (→ correct-cutover) or a confirmed structural mismatch (→ ownership-and-structure).
---

# Minimal Falsifiable Slice

## Overview

Choose the smallest slice that can prove or falsify the next scientific claim.

## Required slice definition

State:

1. Claim being tested
2. Smallest code path that affects the claim
3. Exact files to touch
4. Exact files not to touch
5. Exact run or test that would prove the slice worked

## Rules

1. Do not mix owner rewrites with broad cleanup unless required.
2. Do not add “while I’m here” changes.
3. If a slice cannot be verified directly, it is too large or too vague.

## Anti-patterns

- changing contracts, reporting, and physics owners in one unscoped patch
- adding diagnostic infrastructure before the core owner change exists
- broad cleanup disguised as scientific progress

## Related

- `verification-gate` — the slice must end in a falsifiable pass/fail.
- `ownership-and-structure` / `correct-cutover` — when "small" isn't the issue; the owner is.
- `discriminating-experiment-design` — to design the test the slice is built to run.
