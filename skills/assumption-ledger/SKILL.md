---
name: assumption-ledger
description: Ledger of a result's assumptions and approvals (value sources → provenance). Use when a result or model rests on simplifying assumptions, approximations, fixed parameters, or regime-of-validity choices, and whenever a scientific assumption is proposed or approved — keep one running ledger of each assumption, who approved it, its regime, and which results depend on it, so a broken assumption leads to a known, bounded re-check. Don't use for citing the source of a value (→ provenance), recording a decision and its rationale (→ decision-log-and-commits), quantifying the numeric error a kept assumption induces (→ uncertainty-reporting-gate), or noting a regime or caveat a *paper* established as you read it (→ literature-workflow).
---

Every result depends on conditions: a linearization, a frozen parameter, a neglected term, a regime,
a data caveat. The ledger makes them explicit and ties each to the results it supports, so when one
fails you know which conclusions to re-examine. It is also the record that the researcher approved
the scientific choices the work rests on (→ `researcher-in-the-loop`).

## Each entry
- **The assumption, named specifically**: `β(r) Osipkov–Merritt with r_a = 2 r_h`, `self-gravity
  neglected`, `optically thin`, `Gaia DR3 completeness flat above G = 18`, not "standard approximations".
- **Status**:
  - *proposed*: raised by the assistant, not yet approved, and not yet load-bearing;
  - *declared postulate*: the researcher's own model choice, derived from rather than challenged
    for lacking a citation;
  - *approximation*: a controlled simplification of known physics;
  - *empirical fit*: inherits its source's range.
- **Approved by and when**: an assumption the assistant introduced stays *proposed* until the
  researcher approves it. A result is not reported on the strength of a proposed assumption.
- **Regime of validity**: where it holds and where it breaks (`r ≪ r_t`, `τ ≲ 1`).
- **What depends on it**: the results, figures, and code paths (with a callsite pointer), and
  whether it is load-bearing (would change a conclusion) or cosmetic.

Re-read the ledger when the scope, regime, or data changes: which assumptions just left their range?

## Form
A `docs/assumptions.md` table, a per-result "Assumptions" block, or entries beside a campaign log
all work; keep one place per project. Size the entry to what rides on it: a one-liner for an
exploratory calculation, the full entry for a reported result.

## Related
- `researcher-in-the-loop` — which choices need approval and how they are proposed.
- `provenance` — where a value came from; this records the conditions under which it applies.
- `decision-log-and-commits` — why a choice beat the alternative.
- `uncertainty-reporting-gate` — ledger entries often map to systematic-error terms.
- `null-result-integrity` — a broken assumption may be why a result failed; record both.
