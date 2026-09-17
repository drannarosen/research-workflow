---
name: no-stub-when-done
description: Use when you are about to report a task as complete/implemented/ready — gate that no stub remains in the code you are calling done: a `raise NotImplementedError`, a `TODO`/`FIXME`, a `pass`/`...` placeholder body, or a "not implemented" path contradicts the claim. Either finish the path, or state plainly what is and isn't done instead of claiming completion. Backed by the `no_stub_when_done` Stop hook. Don't use for the run-it-and-show-output discipline (→ verification-gate) or for scoping work down before you start (→ minimal-falsifiable-slice).
---

A completion claim covers behavior, not signatures. A stub left on a path reported as done surfaces
far downstream, where the next person builds on it and the gap is expensive to trace. The
`no_stub_when_done` Stop hook backs this check.

## Before reporting done
- **No `NotImplementedError`, `pass`, or `...` body on the claimed path.** Fill it, or leave it out of
  the claim.
- **No surviving `TODO`/`FIXME`/`XXX` in code called finished.** Resolve it, or move it to an issue
  and say so.
- **No placeholder return flowing downstream as real** (`return None`, `return 0.0  # placeholder`).
- **A signature is scaffolding.** "Implemented" refers to behavior, verified (→ `verification-gate`).
- **Match the claim to the slice you closed.** If you scoped down (→ `minimal-falsifiable-slice`),
  report completion of that slice, not the whole feature.
- **Name the boundary.** "X and Y are implemented and tested; Z is stubbed and out of scope for this
  slice" is useful; "mostly complete" is not. A deliberate stub is fine when it is declared, tracked,
  and named in the status.
- **Docs agree with the code.** A landed change is done when the code, its tests, and the docs it
  touched agree (→ `staleness-sweep`).

## Related
- `verification-gate` — "done" also requires fresh run output, not just the absence of stubs.
- `minimal-falsifiable-slice` — scope the work so "done" is a small, real, fully-closed claim.
- `no-silent-except` — the runtime cousin: an `except: pass` is a stub that hides a failure at run time.
- `decision-log-and-commits` — record a deferred stub as a tracked decision, not a silent gap.
- `staleness-sweep` — bring the docs a change touched up to date before calling it done.
