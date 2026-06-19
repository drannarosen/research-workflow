---
name: assumption-ledger
description: Use when a result or model rests on simplifying assumptions, approximations, fixed parameters, or regime-of-validity choices — keep an explicit running ledger of what each result depends on, so when an assumption later breaks you know exactly which conclusions die with it. Don't use for citing the source of a value (→ provenance-of-constants), recording a decision and its rationale (→ decision-log-and-commits), quantifying the numeric error a kept assumption induces (→ uncertainty-reporting-gate), or noting a regime/caveat a *paper* established as you read it (→ reading-notes-discipline) — this ledger is for your own project's assumptions.
---

Every result carries load-bearing "this is only true if…" clauses — a linearization, a frozen parameter, an ignored term, a regime of validity, a data/instrument caveat. Left implicit, they are invisible until one quietly fails and silently invalidates a conclusion nobody re-examined. Keep them explicit: a living ledger mapping each significant result to the assumptions it stands on, so a broken assumption triggers a known, bounded re-check instead of an undetected wrong answer.

## Keeping the ledger
- **Name the assumption** → the specific simplification (`β(r) fixed to Osipkov–Merritt`, `self-gravity neglected`, `optically thin`, `linear regime`, `Gaia DR3 completeness assumed flat`) — not "standard approximations."
- **State its regime of validity** → where it holds and where it breaks (`valid for r ≪ r_t`, `breaks above τ ~ 1`).
- **Link it to what depends on it** → which results, figures, or conclusions rest on it, so the blast radius of a break is known in advance.
- **Flag the load-bearing ones** → which assumptions, if wrong, would change the conclusion, versus which are cosmetic.
- **Revisit on change** → when scope, regime, or data changes, re-read the ledger: which assumptions just left their domain of validity?

## Anti-patterns
- Assumptions living only in the author's head — invisible to reviewers and to future-you, and unrecoverable after a context switch.
- Burying a load-bearing approximation in a code comment with no link to the results it controls.
- Carrying a result into a new regime without checking whether its assumptions still hold there.
- "We assume standard conditions" — unfalsifiable; name the conditions.

## Hard vs adaptable
- **Hard rule:** the load-bearing assumptions behind a reported result are written down and linked to it. An unstated assumption is an unbounded liability.
- **Adaptable:** the form (a ledger file, a docstring "Assumptions" block, an entry per result) and the granularity — scale to how much rides on the assumption.

This tracks *what a result depends on*. The *source* of a value is `provenance-of-constants`; the *rationale* for a choice is `decision-log-and-commits`; the *numeric error* a kept assumption introduces is `uncertainty-reporting-gate`.

## Related
- `provenance-of-constants` — cites where a value came from; this records the conditions under which it applies.
- `decision-log-and-commits` — the decision and why; this is the standing list of what the decision assumed.
- `uncertainty-reporting-gate` — assumptions in the ledger often map directly to systematic-error terms.
- `null-result-integrity` — a broken assumption may be exactly why a result failed; record both.
