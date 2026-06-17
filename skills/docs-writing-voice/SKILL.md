---
name: docs-writing-voice
description: Use when writing or revising PROSE *or page structure* for Anna's MyST research documentation (software-package docs, the brain `guide/` knowledge hub, design/ADR docs) — to match her pedagogical voice (motivate→frame→formalize, serve new graduate students AND professors at once, quantitative CGS/solar anchoring, active/second-person) AND her docs-as-knowledge-ecosystem page rules (what each page type must contain, how theory↔API↔validation↔references cross-link, onboarding paths). Delegates base prose clarity to elements-of-style:writing-clearly-and-concisely. Don't use for manuscripts/telescope proposals (→ writing-science-voice), grants (→ grant-writing-voice), MyST syntax/project config (→ myst-expert), or visual house style/layout (the brain's brain-local brain-frontend skill).
---

# Docs voice & page anatomy (Anna's MyST research sites)

Write explanatory prose that sounds like Anna and teaches well. The distilled, corpus-grounded
fingerprint (with verbatim exemplars) is
[references/voice-fingerprint.md](references/voice-fingerprint.md) — read it; it's the authority.

## The load-bearing moves

- **Motivate → frame → formalize, never the reverse.** Open with a hook, a reframe, or the reader's
  likely mental state; pose theory as a physical *question* ("How does pressure support the star against
  gravity?"); earn the math. Give intuition/analogy **before** equations.
- **Two audiences in one page.** Keep newcomers in the main flow; route experts past with explicit
  reading paths ("Already know stellar physics? skip to…") and put analogies in `:::{aside}` blocks,
  **bounded** so they can't mislead ("the ML analogy breaks here: …").
- **Quantitative anchoring.** Even prose carries real numbers and a "For the Sun: …" sanity check;
  show scalings and dynamic ranges. Math is LaTeX/KaTeX always (see `brain-frontend`).
- **Active, second-person, varied rhythm.** Runs of medium sentences punctuated by a short hammer;
  **bold** the load-bearing term, *italic* the reader's mistaken assumption.
- **Connect topics.** Cross-link related concepts; end units with a "what we just learned" / bridge.
- **Honest.** Mark inference vs citation; never "it converged / it's elegant" ⇒ "it's correct"
  ("elegant nonsense is still nonsense"); never fabricate a citation or connection.

## Anti-patterns (her good pages never do these)

Open cold with a definition/equation wall · leave a concept abstract · let an analogy stand unbounded ·
assume a single audience · pad with generic prose.

## Register varies by page type

Tutorials/explanations = full hook-first pedagogy. Reference/API pages relax to terser, scannable prose
(still active, still anchored) — don't force a narrative hook onto a reference table.

## Page anatomy (what each page contains, how they connect)

For *structure*, not just voice — the docs site is the project's single source of truth and onboarding
path, a web of theory ↔ API ↔ validation ↔ references. What each page type must contain (landing,
getting-started, theory, API, how-to, validation, dev-log, bibliography), the universal page rules
(frontmatter minimum, orient-in-one-sentence, always link outward, anchor numbers), and the
ecosystem anti-patterns are in [references/page-anatomy.md](references/page-anatomy.md) — read it when
deciding *what goes on the page*, not just how it reads.

## Hand-offs

- **Base clarity / tightening** → `elements-of-style:writing-clearly-and-concisely` (run it after, for
  concision — this skill is the *voice*, that one is the *clarity pass*).
- **mystmd syntax** → `myst-expert`. **Layout/dashboards/badges/math rendering** → `brain-frontend`.
- Manuscripts → `writing-science-voice`; grants → `grant-writing-voice`.
