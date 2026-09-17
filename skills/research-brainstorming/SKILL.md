---
name: research-brainstorming
description: Use when a claim is about to be made or a costly test designed, to refine ONE research direction into a sharp, falsifiable hypothesis through Socratic dialogue — turning a vague direction into a stated hypothesis, the strongest competing alternative, the discriminating observable, and the prediction (with kill criterion) that would change your mind. The research-focused analog of the software brainstorming skill. Don't use to develop the researcher's own model or explore a theoretical question before any claim is at stake (→ model-development), to generate many candidate directions (→ research-ideation), to design the concrete experiment or run that discriminates (→ discriminating-experiment-design), to scope the code (→ minimal-falsifiable-slice), or to design a software feature/architecture (use superpowers brainstorming).
---

A research idea is not ready to *claim* or to spend a costly test on until it is a hypothesis you could be wrong about. It can be developed long before that: if the researcher has brought their own model and wants its consequences, use `model-development` instead — don't force a hypothesis card onto a model still being built. This skill refines one direction, through one-question-at-a-time dialogue, into a falsifiable claim with a named alternative and a discriminating observable. It mirrors the software brainstorming skill, but the output is science — a hypothesis and a prediction — not an architecture.

## The process
- **Start from the seed** → restate the idea in one sentence; ask what observation or intuition motivates it.
- **Ask one question at a time** → prefer sharpening questions: what exactly is claimed, over what regime, compared to what null. Don't stack questions.
- **Force a falsifiable form** → convert "X matters" into "X changes Y by ~Z under conditions C; if not, the hypothesis is wrong."
- **Name the alternative** → what is the most credible competing explanation? A hypothesis with no rival is not sharp yet.
- **Find the discriminating observable** → the measurement that comes out differently under the hypothesis versus the alternative.
- **State the prediction and the kill criterion** → the result that would make you abandon it.
- **Validate incrementally** → reflect the sharpened hypothesis back in small pieces and adjust before moving on.

## Output
A compact hypothesis card:

```text
hypothesis: <one falsifiable sentence>
regime/scope: <where it is claimed to hold>
competing alternative: <the credible rival explanation>
discriminating observable: <what differs between hypothesis and rival>
prediction: <expected signature, with rough effect size>
kill criterion: <result that refutes it>
```

## Anti-patterns
- Unfalsifiable framing ("explore the relationship between …") *offered as the claim itself* — exploration is legitimate work (→ model-development), just not a hypothesis.
- A hypothesis with no named alternative.
- Jumping to method or code before the observable is fixed.
- Confirmation-only predictions with no result that would refute.

## Hard vs adaptable
- **Hard rule (once a claim or costly test is at stake):** a direction is not "sharpened" until it is a falsifiable claim with a named rival and a kill criterion — never carry forward an idea that no result could refute.
- **Adaptable:** how many dialogue rounds, and how formal the hypothesis card, scale to the stakes of the direction.

## Related
- `model-development` — develop the researcher's model (Explore/Develop) before it is sharpened here.
- `research-ideation` — generate and triage the directions this skill sharpens.
- `discriminating-experiment-design` — design the minimal experiment that resolves the observable.
- `literature-workflow` — confirm the sharpened hypothesis is not already answered.
- `adversarial-result-check` — once you have a result, stress-test it.
