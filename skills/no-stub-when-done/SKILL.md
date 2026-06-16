---
name: no-stub-when-done
description: Use when you are about to report a task as complete/implemented/ready — gate that no stub remains in the code you are calling done: a `raise NotImplementedError`, a `TODO`/`FIXME`, a `pass`/`...` placeholder body, or a "not implemented" path contradicts the claim. Either finish the path, or state plainly what is and isn't done instead of claiming completion. Backed by the `no_stub_when_done` Stop hook. Don't use for the run-it-and-show-output discipline (→ evidence-first-execution) or for scoping work down before you start (→ minimal-falsifiable-slice).
---

"Done" means the code does what you said — not that the function signature exists with `raise NotImplementedError` inside. Claiming a feature is complete while a stub, `TODO`, or placeholder body still sits on the implemented path is the most corrosive kind of overclaim: the next person (often future-you) builds on a foundation that was never poured, and the gap surfaces far downstream where it is expensive to trace. Default: before reporting completion, the path you claim is done has no stub on it; if part is deliberately out of scope, that is stated, not silently left behind a "complete."

## Before you say "done"
- **No `NotImplementedError` / `pass` / `...` on the claimed path** → a placeholder body is the literal opposite of implemented. Fill it or don't claim it.
- **No surviving `TODO`/`FIXME`/`XXX`** in code you are calling finished → a TODO is a written admission the work isn't done. Resolve it, or move it to an issue and *say so*.
- **State the boundary explicitly** → "X and Y are implemented and tested; Z is stubbed and out of scope for this slice" is honest and useful. "It's complete" when Z is stubbed is not.
- **A signature is not an implementation** → adding the function/class/CLI flag is scaffolding; the claim "implemented" refers to behavior, verified (→ evidence-first-execution).
- **Match the claim to the slice you actually closed** → if you scoped down (→ minimal-falsifiable-slice), report completion of *that* slice, not the whole feature.

## Anti-patterns
- `def solve(...): raise NotImplementedError` shipped under "the solver is implemented."
- A `# TODO: handle the non-convergent case` left in, while reporting "handles all cases."
- A placeholder return (`return None` / `return 0.0  # placeholder`) flowing downstream as if real.
- "Done" for a function whose body is `pass` or `...` because the signature and docstring exist.
- Burying a known gap in prose ("mostly complete") instead of naming exactly what is unfinished.

## Hard vs adaptable
- **Hard rule:** do not report a task complete/implemented/ready while a stub or `TODO` remains on the path you are calling done. Finish it, or restate scope.
- **Adaptable:** a deliberate, *declared* stub is fine — explicitly out-of-scope, tracked, and named in the status. What must survive: the completion claim never covers code that doesn't exist yet.

## Related
- `evidence-first-execution` — "done" also requires fresh run output, not just the absence of stubs.
- `minimal-falsifiable-slice` — scope the work so "done" is a small, real, fully-closed claim.
- `no-silent-except` — the runtime cousin: an `except: pass` is a stub that hides a failure at run time.
- `decision-log-and-commits` — record a deferred stub as a tracked decision, not a silent gap.
