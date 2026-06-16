---
name: ai-self-distrust
description: Use when relying on code, math, or facts the AI assistant itself produced — apply EXTRA scrutiny precisely because the model's signature failure is confident fabrication: hallucinated library APIs, plausible-but-wrong algebra, invented constants/citations, and tests written to pass rather than to catch. The stance that points generic skepticism at the assistant's own output. Don't use as the concrete check itself — route to the specific gate: API existence (→ verify against docs), formulas (→ derivation-before-implementation), constants/citations (→ provenance-of-constants), result size (→ plausibility-envelope), test/claim integrity (→ evidence-first-execution).
---

The assistant's most dangerous output is the one that looks right. An LLM (this one included) will produce fluent code calling functions that don't exist, algebra with a sign quietly wrong, a constant to ten digits it never sourced, and a test contorted to pass — all delivered with the same confidence as correct work. When you are accepting *AI-generated* artifacts, raise scrutiny rather than lower it: fluency is not evidence, and the human-in-the-loop is the one check the model cannot talk past.

## Where AI fabrication hides — and the gate it earns
- **Hallucinated APIs** → a called function, signature, or kwarg that doesn't exist or has changed. Verify against the actual docs/source (e.g. Context7) before relying on it — don't trust a call because it reads plausibly.
- **Plausible-but-wrong math** → a derivation with a dropped factor or flipped sign. Route to `derivation-before-implementation` + `plausibility-envelope`; never accept symbolic work because it "looks standard."
- **Invented constants / citations** → a precise-looking number, or a paper/equation reference that doesn't exist. Route to `provenance-of-constants`; resolve every citation rather than assuming it's real.
- **Tests that assert the bug** → a test written to pass the current (possibly wrong) output, or weakened to go green. Route to `evidence-first-execution` and the test-integrity gate.
- **Confident "it works"** → an unsupported done/passing claim. Demand the command output (→ evidence-first-execution / the evidence gate).

## Anti-patterns
- Accepting AI-written code because it is syntactically clean and well-commented — fabrication is *especially* well-commented.
- Trusting a number or citation the assistant produced without resolving it to a real source.
- Letting the assistant both write a result and certify it ("I verified this") with no independent check — the model grading its own exam.
- Lowering scrutiny because the task seemed easy; easy tasks are where confident fabrication slips through unread.

## Hard vs adaptable
- **Hard rule:** AI-produced code/math/facts are not trusted on the strength of fluency; each high-risk class (API, formula, constant, test, claim) is checked by its specific gate before it ships.
- **Adaptable:** how much scrutiny per item — scale to blast radius (a one-off plot vs. a force kernel). What must survive: *the assistant does not get the benefit of the doubt on its own output.*

This is the umbrella stance; it does not replace the concrete gates — it tells you *when to reach for them hardest*: whenever the artifact came from the model.

## Related
- `evidence-first-execution` — a confident "done/passing" from the assistant needs fresh command output.
- `derivation-before-implementation` / `plausibility-envelope` — for AI-produced math and numbers.
- `provenance-of-constants` — for AI-produced constants and citations.
- `researcher-in-the-loop` — the human supervisor is the check the model cannot rationalize past.
