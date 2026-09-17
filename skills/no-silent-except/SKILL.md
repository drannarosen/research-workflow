---
name: no-silent-except
description: No silently swallowed exceptions (bare except, pass-only handlers). Use when writing or reviewing exception handling in research code — gate that no error is silently swallowed: a bare `except:`, or an `except ...:` whose only body is pass/.../continue, hides the NaN, the non-convergence, the failed solve, and the dropped data point that research must see. Catch narrowly and handle, log-and-re-raise, or let it propagate — never absorb. Backed by the `no_silent_except` hook. Don't use for the floating-point NaN/Inf-guarding facet specifically (→ numerical-precision) or the general evidence-before-done discipline (→ verification-gate).
---

A swallowed exception silently corrupts a result. `except: pass` (or `except Exception: pass`)
turns a solver that diverged, a fit that failed, a file that didn't load, or an array that went NaN
into a clean-looking run that produces a wrong number, and because it doesn't crash, nobody
investigates. A caught error is handled, logged with context and re-raised, or allowed to propagate.
How to respond (retry, fallback with a logged warning, re-raise with context) depends on the failure;
what matters is that the failure stays visible. The `no_silent_except` hook flags the canonical
pattern.

## Handling an exception
- **Catch narrowly**: `except ValueError`, not bare `except:` or `except Exception`. A broad catch
  hides the error you didn't anticipate, and a bare except also catches
  `KeyboardInterrupt`/`SystemExit`. A broad `try` around many lines has the same effect: one catch
  absorbs several different failures.
- **Do something real**: recover meaningfully, or log with context and re-raise. Propagating is better
  than silencing. Converting a hard failure into a default or `None` that flows downstream unflagged is
  silencing.
- **Don't drop data silently**: an `except: continue` that skips bad inputs is a silent selection
  effect. Count, log, and report what was skipped (→ `adversarial-result-check`, lane 5).
- **An intended no-op is explicit and narrow**: `except FileNotFoundError: pass  # optional cache,
  regenerated below`, so the intent is auditable. This is rare.
- **The same applies to NaN/Inf**: `nan_to_num` or a silent isnan-skip is the float-domain version
  (→ `numerical-precision`).

## Related
- `numerical-precision` — the float-domain twin: don't let NaN/Inf flow silently into a result.
- `verification-gate` — a run that "passed" because it swallowed its own errors is not evidence.
- `adversarial-result-check` — silently skipped (errored) inputs are a selection bias.
- `researcher-in-the-loop` — the reporting standard a silently degraded run would violate.
