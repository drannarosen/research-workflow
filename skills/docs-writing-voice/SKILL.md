---
name: docs-writing-voice
description: Write MyST docs prose and page structure in house voice (syntax → myst-expert). Use when writing or revising PROSE *or page structure* for the researcher's MyST research documentation (software-package docs, knowledge-hub sites, design/ADR docs) — to match the plugin's default house voice (motivate→frame→formalize, serve new graduate students AND professors at once, quantitative CGS/solar anchoring, active/second-person) AND its docs-as-knowledge-ecosystem page rules (what each page type must contain, how theory↔API↔validation↔references cross-link, onboarding paths); a project can override the house voice. Delegates base prose clarity to elements-of-style:writing-clearly-and-concisely. Don't use for manuscripts/telescope proposals (→ writing-science-voice), grants (→ grant-writing-voice), MyST syntax/project config (→ myst-expert), or visual layout conventions (the project's own style guide or frontend tooling).
---

# Docs voice and page anatomy

This is the plugin's default house voice for MyST research documentation: explanatory prose that
teaches well. A project that sets its own voice (in its CLAUDE.md or docs style guide) overrides it;
follow the project where they differ. The corpus-grounded fingerprint, with verbatim exemplars, is
[references/voice-fingerprint.md](references/voice-fingerprint.md) and is the authority for the
house voice.

## The load-bearing moves

- **Motivate → frame → formalize.** Open with a hook, a reframe, or the reader's likely mental state;
  pose theory as a physical question ("How does pressure support the star against gravity?"); earn
  the math. Give intuition or an analogy before equations, not a cold definition or equation wall.
- **Two audiences in one page.** Keep newcomers in the main flow; route experts past with explicit
  reading paths ("Already know stellar physics? skip to…") and put analogies in `:::{aside}` blocks,
  bounded so they can't mislead ("the ML analogy breaks here: …").
- **Quantitative anchoring.** Prose carries real numbers and a "For the Sun: …" sanity check; show
  scalings and dynamic ranges rather than leaving a concept abstract. Math is LaTeX/KaTeX (see
  `myst-expert`).
- **Active, second-person, varied rhythm.** Runs of medium sentences punctuated by a short one;
  **bold** the load-bearing term, *italic* the reader's mistaken assumption. No generic padding.
- **Connect topics.** Cross-link related concepts; end units with a "what we just learned" or bridge.
- **Honest about status.** Mark inference vs citation; a method that converged or looks elegant is not
  thereby correct; citations and connections are real ones.

## Register varies by page type

Tutorials and explanations get full hook-first pedagogy. Reference/API pages relax to terser,
scannable prose (still active, still anchored); don't force a narrative hook onto a reference table.

## Page anatomy

The docs site is the project's single source of truth and onboarding path, a web of theory ↔ API ↔
validation ↔ references. What each page type must contain (landing, getting-started, theory, API,
how-to, validation, dev-log, bibliography), the universal page rules (frontmatter minimum,
orient-in-one-sentence, always link outward, anchor numbers), and the ecosystem anti-patterns are in
[references/page-anatomy.md](references/page-anatomy.md). Read it when deciding what goes on the page.
Pages a code change touched are updated in the same change (→ `staleness-sweep`).

## Related

- **Base clarity / tightening** → `elements-of-style:writing-clearly-and-concisely` (run it after, for
  concision — this skill is the *voice*, that one is the *clarity pass*).
- **mystmd syntax** → `myst-expert`. **Layout/dashboards/badges/visual conventions** → the project's own
  style guide or frontend tooling.
- Manuscripts → `writing-science-voice`; grants → `grant-writing-voice`.
- `staleness-sweep` — docs that a landed change touched stay current with the code.
