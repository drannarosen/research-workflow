---
name: no-silent-except
description: Use when writing or reviewing exception handling in research code — gate that no error is silently swallowed: a bare `except:`, or an `except ...:` whose only body is pass/.../continue, hides the NaN, the non-convergence, the failed solve, and the dropped data point that research must see. Catch narrowly and handle, log-and-re-raise, or let it propagate — never absorb. Backed by the `no_silent_except` hook. Don't use for the floating-point NaN/Inf-guarding facet specifically (→ numerical-precision) or the general evidence-before-done discipline (→ evidence-first-execution).
---

A swallowed exception is a result silently corrupted. `except: pass` (or `except Exception: pass`, or a bare `except:`) turns a solver that diverged, a fit that failed, a file that didn't load, or an array that went NaN into a clean-looking run that quietly produces a wrong number. In research code this is the worst failure class: it doesn't crash, so nobody investigates. Default: an exception is handled, logged-and-re-raised, or allowed to propagate — never caught and dropped.

## Handling an exception
- **Catch narrowly** → `except ValueError`, not bare `except:` and not `except Exception`. A broad catch hides the error you didn't anticipate (including `KeyboardInterrupt`/`SystemExit` for a bare except).
- **Do something real** → recover meaningfully, or log *with context* and re-raise. Letting it propagate is better than silencing it.
- **Never drop data silently** → an `except: continue` that skips bad inputs is a silent selection effect; count, log, and report what was skipped (→ systematic-error-hunting).
- **If a no-op is genuinely intended** → it is rare; make it explicit and narrow (`except FileNotFoundError: pass  # optional cache, regenerated below`) so the intent is auditable.
- **Don't mask NaN/Inf either** → the numeric cousin: `nan_to_num`/silent isnan-skip is the same sin in float form (→ numerical-precision).

## Anti-patterns
- `except: pass` / `except Exception: pass` / `except ...: ...` — the canonical silent swallow.
- A broad `try` wrapping many lines so any of several failures is absorbed by one catch.
- `except Exception: continue` in a loop, silently dropping every item that errored.
- Catching to convert a hard failure into a default/`None` that flows downstream unflagged.

## Hard vs adaptable
- **Hard rule:** no exception is silently swallowed. A caught error is handled, logged-and-re-raised, or propagated — and a deliberate no-op carries a comment justifying it.
- **Adaptable:** how to respond (retry, fallback with a logged warning, re-raise with context) — match the failure. What must survive: *the failure is visible*, never absorbed into a clean-looking result.

## Related
- `numerical-precision` — the float-domain twin: don't let NaN/Inf flow silently into a result.
- `evidence-first-execution` — a run that "passed" because it swallowed its own errors is not evidence.
- `systematic-error-hunting` — silently skipped (errored) inputs are a selection bias.
- `ai-self-distrust` — AI-written try/except is a common place a `pass` gets inserted to make code "run."
