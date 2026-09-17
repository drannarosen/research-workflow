---
title: Default house voice for documentation and teaching prose — fingerprint
type: reference
status: source-backed
updated: 2026-09-16
---
(docs-voice-fingerprint)=
# Default house voice for documentation and teaching prose — fingerprint

A source-backed distillation of the plugin's default voice for **explanatory / pedagogical MyST prose** (docs and course material), grounding the `docs-writing-voice` skill. Every trait below quotes real published-style exemplars. This is *documentation* voice — distinct from manuscript/proposal voice (see `writing-science-voice`) and grant voice. Where the corpus is thin on an axis, it says so.

**Corpus sampled (8 pages read in full, ~12 more skimmed for structure):**
- a stellar-structure package's foundations page for machine-learning readers — *richest* for cross-audience pedagogy
- the same package's "from physics to solver to inference" overview — *richest* for first-principles framing + structure habits
- the same package's common-misconceptions page — *richest* for the "debug your intuition" device and anti-pattern stance
- the same package's timescales theory page — quantitatively anchored theory prose
- an initial-conditions package's theory page on IC philosophy — definition-first reference/theory prose
- a computational-astrophysics course site's numerical-methods module overview — narrative-hook course prose
- the same course site's "why this course is different" page — motivation / stance prose
- a pedagogy tool's design-explanation page on pedagogical foundations — design-explanation prose
- a knowledge hub's internal guide pages (mental model; staying lean) — internal how-to-use docs

---

## 1. Stance & pedagogy: motivate → frame → formalize, never the reverse

The voice **almost never opens with a definition or an equation.** It opens with a hook, a reframe, or the reader's likely starting mental state, then earns the formalism.

- **Reframe the intimidating thing as familiar** before any math:
  > "If you come from machine learning, a stellar model can look like an intimidating pile of specialized notation. The good news is that the central ideas are not exotic. A stellar model is a constrained physical system with state variables, source terms, transport laws, and boundary conditions." (package foundations page)

- **A single sharp thesis sentence** that reorients the reader, often italic/bold for the pivot:
  > "What changes is the physics vocabulary. And one crucial distinction: the forward pass is not 'predict outputs from inputs.' The forward pass is **solve the star.**" (package foundations page)

- **Narrative hook → twist → moral** in course prose (the Richardson weather story):
  > "Reality delivered a crushing blow: the actual change was 1 millibar… But here's the twist: Richardson's equations were correct… **The errors in numerical approximation completely overwhelmed the physics.**" (course module overview)

- **Pose the physical question, then answer it.** Theory sections are organized as questions, not topics:
  > "### 2. Hydrostatic balance — How does pressure support the star against gravity? … Gravity pulls inward; pressure pushes outward. In a stable star, they balance almost exactly." (package foundations page)

- **First-principles, but with explicit permission to skip the derivation:**
  > "The [Theory] section derives them in full, but you do not need the derivations to read `<package>`. You need the physical picture: four coupled questions, solved together." (package foundations page)

- **The Observable→Model→Inference spine is explicit**, named as a pipeline:
  > "stellar physics, numerical solvers, automatic differentiation, and statistical inference are not separate tools bolted together. They are stages in a single scientific pipeline." (package overview page)

## 2. Audience handling: two readers at once, via layered asides and "why it matters"

The voice routinely serves a newcomer and an expert in the same page. The mechanisms are concrete:

- **`:::{aside}` blocks that route the already-expert reader away**, so the main flow stays beginner-paced:
  > ":::{aside} **Already know stellar physics?** If you understand stellar structure but want the autodiff and inference side, go directly to [Machine Learning for Stellar Astrophysics Students]…" (package foundations page)

- **Analogies pitched to a *specific* second audience**, then immediately bounded so they don't mislead:
  > "If you want a machine learning analogy, EOS, opacity, and nuclear rates are not weights in a neural network. They are domain-specific physical operators — closer to the physics engine in a differentiable simulator than to a parameterized model." (package foundations page)
  > "That translation is imperfect, but it is enough to orient yourself." (same)

- **Explicit "why this matters" framing** that connects mechanics to stakes (LIGO/JWST/cosmo sims):
  > "You NEED to understand numerical methods at a fundamental level – not just which buttons to push, but why algorithms succeed or fail." (course module overview)

- **Multiple reading paths offered up front** (Fast Track / Standard / Deep) via grid cards ("Choose Your Learning Path" in the course module overview), and "read this first" / "read this once" orientation lines:
  > "Read this once and the rest of the system explains itself." (knowledge-hub mental-model page)
  > "Read it first if you are new to the package." (IC-philosophy theory page)

## 3. Connecting topics: dense, deliberate cross-linking + "everything is coupled"

- **Inline MyST xrefs to the canonical home of each concept**, rather than re-explaining — e.g. linking to `[gravitational energy]`, `[Theory]`, ADR refs `{ref}`adr-0008-…``. (timescales page, knowledge-hub mental-model page)

- **Link *and* say why you'd follow the link** ("a good next step is X if you want a first model, or Y if you want the equations first"):
  > "You are now ready for the more formal parts of the site. A good next step is [**Getting Started**] for a first model, or [**Theory**] if you want the equations first." (package overview page, Bridge block)

- **A recurring conceptual through-line: nothing is local / everything is coupled** — topics connect by tracing a causal chain:
  > "Increase the opacity in the envelope, and the temperature gradient steepens. That shifts the boundary between radiative and convective zones. The convective zone changes the surface temperature… Nothing is local." (package foundations page)

- **Tables used as cross-concept translators** ("ML concept ↔ stellar astrophysics analogue"; "Traditional Approach ↔ Research Reality"; term-glossary tables). (package foundations page, course motivation page, knowledge-hub mental-model page)

## 4. Sentence rhythm & diction

- **Active voice, second person, direct address.** "You do not fit them. You look them up." (package foundations page). "You're about to discover…" (course module overview).
- **Deliberate sentence-length variation for emphasis**: a run of medium sentences punctuated by a very short hammer. "A dense core occupies little volume. A tenuous envelope occupies a lot." / "Nothing is local." / "A main-sequence star does neither." (package foundations page)
- **Parallelism / triads** as a structural device: "state variables, source terms, transport laws, and boundary conditions"; "the physics is one codebase, the fitting procedure is another, the sensitivity study is manual…" (package overview page)
- **Low hedging in explanation; precise hedging where honesty requires it.** State things plainly ("The forward pass is solve the star") but flag uncertainty explicitly when it can't be verified: "I'm naming the body of work, not specific papers I can verify by memory. Treat these as starting points for literature review, not definitive citations." (pedagogical-foundations page)
- **Bold for the load-bearing term/pivot, italics for emphasis or for the reader's mistaken assumption.** Term-introductions are bolded on first use ("**enclosed mass** $m$", "**constitutive physics**"). (package foundations page)
- **Intuition-before-math is the default ordering**: physical picture first, then the closed-form, then a worked solar number. (timescales page, package foundations page)

## 5. Quantitative anchoring (a strong, consistent fingerprint)

Even "explanatory" prose anchors abstractions to **real numbers in CGS / solar units**, frequently with a "For the Sun:" sanity-check:

> "At the Sun's center ($\rho \sim 150$ g/cm$^3$, $T \sim 1.57 \times 10^7$ K), the gas is nearly ideal." (package foundations page)
> "**For the Sun:** $t_{\rm dyn} \approx 27$ minutes." (timescales page — every timescale gets a "For the Sun:" line)
> "The present-day Sun is $\sim$30% more luminous and $\sim$10% larger than its ZAMS counterpart." (common-misconceptions page)

Scaling relations are written with explicit power-law dependences and fiducial normalizations, and "dynamic range" tables (center vs surface vs ratio) are a recurring device. (timescales page, package foundations page)

## 6. Structure habits

- **MyST admonitions are a core voice element, used with consistent intent:**
  - `:::{aside}` — route a different audience / give an optional deeper note (very frequent in package docs and hub guides).
  - `:::{note} What We Just Learned` — a recap block closing a conceptual page. (package overview page)
  - `:::{warning}` — a draft-status banner *and* an anti-pattern flag ("Don't duplicate code…", "Don't fabricate"). (knowledge-hub staying-lean page)
  - `:::{note} **TL;DR:**` with `:class: dropdown` — collapsible executive summary at the top of long course pages. (course motivation page)
- **Custom interactive callouts in course and package-docs prose** rendered as blockquotes with emoji labels:
  > "> 🤔 **Quick Check** … > 🌉 **Bridge** … :::{note} What We Just Learned" (package overview page)
  (These three — Quick Check, Bridge, What We Just Learned — recur as a pedagogical scaffold.)
- **Numbered/named conceptual units** rather than bare headings: "The four physical questions", "The three constitutive ingredients", "Three things every initial condition fixes" — count the pieces and tell the reader the count first.
- **Rich tables**: translation tables, comparison tables, `{list-table}`/`{grid}` directives, and the "For the Sun" comparison tables.
- **Math placement**: display equations carry MyST labels (`(eq:t-dyn)`) for cross-reference; each equation is sandwiched by a plain-language reading of what it *measures* before and a numeric instantiation after.
- **Frontmatter discipline**: `title` + `subtitle` + `description` (the subtitle is itself a one-line thesis, e.g. "Three clocks that govern stellar life"); explanatory pages carry provenance/status fields (`status: draft`, `last_audited`, `confidence: source-backed`).

## 7. Tone: warm, direct, intellectually honest, lightly playful

- **Encouraging without being soft** — names the difficulty, then reassures: "The good news is that the central ideas are not exotic." (package foundations page); "make interdisciplinary entry feel welcoming instead of remedial" (an author's figure-suggestion note on the same page).
- **Memorable, slightly pugnacious one-liners** carry the message: "elegant nonsense is still nonsense." (package overview page); "a hub you can't trust is a hub you stop using." (knowledge-hub staying-lean page); "Every knowledge system dies the same death." (same).
- **Honesty as a stated value, not just a behavior** — call out inference vs. citation, and bake "no fabrication" into the prose itself. (pedagogical-foundations page, knowledge-hub staying-lean page)
- **Restrained, purposeful humor / vividness**: "spheres of glowing gas" that turn out "surprisingly nasty" numerically (package foundations page); "Mazur's Peer Instruction with a fresh coat of paint" as a quality bar (pedagogical-foundations page). Emoji appear as *functional* labels (🤔 🌉 🎯), not decoration.
- **Motivational claims are evidence-cited**, not hand-waved: pedagogy is backed with named literature (Schwartz 2008, Ting & O'Briain 2025, Tetlock, Dunlosky/Rawson). (course motivation page, pedagogical-foundations page)

## 8. Anti-patterns good pages avoid

Inferred from the consistent positive practice above (and from explicit "anti-patterns" sections in the corpus):

- **Never opens cold with a formal definition or a wall of equations** — always a hook/reframe/question first.
- **Never leaves a concept abstract** — there is almost always a number, a "For the Sun," or a concrete causal chain.
- **Never lets an analogy stand unbounded** — state its limits in the same breath ("That translation is imperfect…").
- **Never conflates "it ran / it converged / it's elegant" with "it's correct."** A whole page exists to attack this: "Convergence means validation" is Misconception #1; "elegant nonsense is still nonsense." (common-misconceptions page, package overview page)
- **Never fabricates a citation or a connection** — flag inferences explicitly; "No documented connection found" beats an invented link. (knowledge-hub staying-lean page, pedagogical-foundations page)
- **Never assumes one audience** — layered asides and explicit reading paths instead of a single pitch level.
- **Never buries the stakes** — "why this matters" is surfaced, not assumed.

---

## Thin-corpus caveats (be honest about coverage)

- **Humor** is present but *restrained*; the sample shows wit and vivid phrasing more than jokes. Don't over-rotate toward comedy.
- The **interactive scaffold blocks** (🤔 Quick Check / 🌉 Bridge / What We Just Learned) are strongly attested in package foundations pages and course prose, but are *not* universal — terse internal hub reference pages and definition-first theory pages mostly omit them. Use them for *teaching* pages, not every reference page.
- **Reference-type pages** (hub reference pages, definition-first theory pages) are terser and more definition-forward than the foundations/course pages — the "hook-first" rule relaxes for pure reference material, though even there pages open with an orientation sentence ("Read this once…", "Read it first if you are new…").
- Pages flagged `status: draft` sometimes carry `<!-- FIGURE SUGGESTION -->` author-notes; these reveal intent (e.g. "make interdisciplinary entry feel welcoming instead of remedial") but are not published prose.
