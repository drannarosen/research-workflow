---
description: Reference-parity audit against an external reference, loading the matching domain lens.
argument-hint: <reference, e.g. mesa | rebound | a paper's Table 2>
---
Use the `reference-parity-audit` skill to plan and run a parity check of our implementation against: $ARGUMENTS

Steps:
1. If the reference matches a shipped lens (`mesa`, `nbody`/REBOUND), load that lens for its domain-specific gotchas before designing the comparison.
2. Identify the exact quantities to compare and, for each, the tolerance it must meet and *why* that tolerance.
3. Pin a matched configuration — same initial conditions, units, and float precision as the reference — so a mismatch is physics, not setup.
4. Run the comparison and report agreement per quantity. Treat any quantity outside tolerance as a finding to explain, never a rounding aside to wave off.

If no reference was given, ask which reference (and which quantities) to audit against before proceeding.
