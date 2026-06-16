---
name: null-result-integrity
description: Use when an experiment, fit, or test fails, shows no effect, or contradicts the hypothesis — gate that the negative result is recorded honestly rather than buried, deleted, or retried with new settings until it flips. A non-effect is a result. Don't use for logging successful runs in general (→ experiment-tracking), recording a design decision and its rationale (→ decision-log-and-commits), or red-teaming a positive result you already believe (→ adversarial-result-check).
---

A result that didn't go your way is data, not a failure to be hidden. When a run shows no signal, a fit won't converge, or the numbers contradict the hypothesis, the integrity move is to *record it as a finding* — not to silently re-run with new settings until it flips, drop the branch, or remember only the run that "worked." The buried null result is how a codebase fools its own author.

## Recording a negative honestly
- **Log it like a positive** → the null/failed result gets the same (config + commit + metrics) record as a success (→ experiment-tracking). "It didn't work" with no captured run is an anecdote, not a finding.
- **Distinguish null from broken** → a genuine no-effect vs. a bug/misconfiguration. Rule out the latter (it ran, inputs were right, the pipeline is sound) before recording a null — and state which it is.
- **Don't tune until it flips** → re-running with changed seeds/cuts/priors until significance appears is p-hacking. If you explore, record *all* attempts, not the lucky one (pairs with seed-and-stochasticity reporting and trials/look-elsewhere accounting).
- **Keep the disconfirming run** → don't `git rm` the branch that falsified the idea; it is the evidence that the idea was actually tested.
- **Update the claim** → a hypothesis the result contradicts is revised or retired in the record, not silently re-scoped to dodge the contradiction.

## Anti-patterns
- Re-running an experiment with quietly different settings until it yields the desired answer, then reporting only that one.
- Deleting failed runs/branches so the history shows only successes — survivorship bias baked into the repo.
- Reclassifying a contradicting result as "a bug" with no evidence it actually is one.
- Reporting "promising" from the single seed that worked among ten that didn't.

## Hard vs adaptable
- **Hard rule:** a negative/failed/contradicting result is recorded, not buried; what falsified an idea is preserved. Suppressing disconfirming evidence is the one move research integrity cannot survive.
- **Adaptable:** where it's recorded (run log, decision log, a `NEGATIVE_RESULTS` note) and how much detail — scale to how surprising or load-bearing the null is.

This governs *honesty about outcomes that went the wrong way*. The general run record is `experiment-tracking`; stress-testing a result you *do* believe is `adversarial-result-check`.

## Related
- `experiment-tracking` — a null result is logged with the same rigor as a positive one.
- `adversarial-result-check` — the converse: attack the results you like; this preserves the ones you don't.
- `decision-log-and-commits` — record the decision to retire or revise a hypothesis a null contradicts.
- `uncertainty-reporting-gate` — "no detection" is a statement about an upper limit and its uncertainty.
