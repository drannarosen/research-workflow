---
name: null-result-integrity
description: Record failed, null, or contradicting results honestly; no p-hacking or burying. Use when an experiment, fit, or test fails, shows no effect, or contradicts the hypothesis — gate that the negative result is recorded honestly rather than buried, deleted, or retried with new settings until it flips. A non-effect is a result. Don't use for logging successful runs in general (→ run-reproducibility), recording a design decision and its rationale (→ decision-log-and-commits), or red-teaming a positive result you already believe (→ adversarial-result-check).
---

A run that shows no signal, a fit that won't converge, or numbers that contradict the prediction is a
finding. Record it and bring it to the researcher. A mismatch with an approved prediction
(→ `researcher-in-the-loop`) points at an assumption or a step; say which one before changing anything.

## Recording a negative
- **Log it like a positive.** The null or failed result gets the same record as a success at the same
  stage (→ `run-reproducibility`): for an exploratory run, command, commit, and prediction vs result.
- **Distinguish null from broken.** Rule out a bug or misconfiguration (it ran, the inputs were right,
  the pipeline is sound) before recording a null, and state which it is. Reclassifying a contradicting
  result as "a bug" needs evidence that it is one.
- **Record every attempt.** Re-running with changed seeds, cuts, or priors until significance appears
  is p-hacking. If you explore, record all attempts, not the one that worked; one seed in ten is not
  "promising" (→ `uncertainty-reporting-gate` for trials/look-elsewhere accounting). Changing settings
  after a mismatch is a new experiment, proposed as one.
- **Keep the disconfirming run.** Don't `git rm` the branch that falsified the idea; it is the
  evidence that the idea was tested.
- **Update the claim.** A contradicted hypothesis is revised or retired in the record, not re-scoped
  to avoid the contradiction.

Where it is recorded (run log, decision log, a `NEGATIVE_RESULTS` note) and how much detail scale with
how surprising or load-bearing the null is.

## Related
- `run-reproducibility` — a null result is logged with the same rigor as a positive one.
- `adversarial-result-check` — the converse: attack the results you like; this preserves the ones you don't.
- `decision-log-and-commits` — record the decision to retire or revise a hypothesis a null contradicts.
- `uncertainty-reporting-gate` — "no detection" is a statement about an upper limit and its uncertainty.
- `researcher-in-the-loop` — the approved prediction a null is compared against.
