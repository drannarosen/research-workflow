---
title: Anna Rosen's documentation / teaching writing voice — fingerprint
type: reference
status: source-backed
updated: 2026-06-06
---
(docs-voice-fingerprint)=
# Anna Rosen's documentation / teaching writing voice — fingerprint

A source-backed distillation of how Anna writes **explanatory / pedagogical MyST prose** (docs and course material), to ground a "docs-writing-voice" skill. Every trait below cites a real page and quotes her actual words. This is *documentation* voice — distinct from her manuscript/proposal voice (see `writing-science-voice`) and her grant voice. Where the corpus is thin on an axis, it says so.

**Corpus sampled (8 read in full, ~12 more skimmed for structure):**
- `stellax/docs/website/foundations/stellar-astrophysics-for-machine-learning-students.md` — *richest* for cross-audience pedagogy
- `stellax/docs/website/foundations/from-physics-to-solver-to-inference.md` — *richest* for first-principles framing + structure habits
- `stellax/docs/website/foundations/common-misconceptions.md` — *richest* for the "debug your intuition" device and anti-pattern stance
- `stellax/docs/website/theory/timescales.md` — quantitatively-anchored theory prose
- `progenax/docs/website/10-theory/ic-philosophy.md` — definition-first reference/theory prose
- `Teaching/astr596-.../07-numerical-methods/module-1-foundations-of-discrete-computing/00-mod1-overview.md` — narrative-hook course prose
- `Teaching/astr596-.../01-course-info/06-why-astr596-is-different.md` — motivation / stance prose
- `Teaching/sophie/docs/website/explanation/pedagogical-foundations.md` — design-explanation prose
- `brain/guide/explanation/mental-model.md` and `.../staying-lean.md` — internal how-to-use docs

---

## 1. Stance & pedagogy: motivate → frame → formalize, never the reverse

She **almost never opens with a definition or an equation.** She opens with a hook, a reframe, or the reader's likely starting mental state, then earns the formalism.

- **Reframe the intimidating thing as familiar** before any math:
  > "If you come from machine learning, a stellar model can look like an intimidating pile of specialized notation. The good news is that the central ideas are not exotic. A stellar model is a constrained physical system with state variables, source terms, transport laws, and boundary conditions." (`stellar-astrophysics-for-ml-students`)

- **A single sharp thesis sentence** that reorients the reader, often italic/bold for the pivot:
  > "What changes is the physics vocabulary. And one crucial distinction: the forward pass is not 'predict outputs from inputs.' The forward pass is **solve the star.**" (`stellar-astrophysics-for-ml-students`)

- **Narrative hook → twist → moral** in course prose (the Richardson weather story):
  > "Reality delivered a crushing blow: the actual change was 1 millibar… But here's the twist: Richardson's equations were correct… **The errors in numerical approximation completely overwhelmed the physics.**" (`mod1-overview`)

- **Pose the physical question, then answer it.** Theory sections are organized as questions, not topics:
  > "### 2. Hydrostatic balance — How does pressure support the star against gravity? … Gravity pulls inward; pressure pushes outward. In a stable star, they balance almost exactly." (`stellar-astrophysics-for-ml-students`)

- **First-principles, but with explicit permission to skip the derivation:**
  > "The [Theory] section derives them in full, but you do not need the derivations to read `stellax`. You need the physical picture: four coupled questions, solved together." (`stellar-astrophysics-for-ml-students`)

- **The Observable→Model→Inference spine is explicit** in stellax (she names it as a pipeline):
  > "stellar physics, numerical solvers, automatic differentiation, and statistical inference are not separate tools bolted together. They are stages in a single scientific pipeline." (`from-physics-to-solver-to-inference`)

## 2. Audience handling: two readers at once, via layered asides and "why it matters"

She routinely serves a newcomer and an expert in the same page. The mechanisms are concrete:

- **`:::{aside}` blocks that route the already-expert reader away**, so the main flow stays beginner-paced:
  > ":::{aside} **Already know stellar physics?** If you understand stellar structure but want the autodiff and inference side, go directly to [Machine Learning for Stellar Astrophysics Students]…" (`stellar-astrophysics-for-ml-students`)

- **Analogies pitched to a *specific* second audience**, then immediately bounded so they don't mislead:
  > "If you want a machine learning analogy, EOS, opacity, and nuclear rates are not weights in a neural network. They are domain-specific physical operators — closer to the physics engine in a differentiable simulator than to a parameterized model." (`stellar-astrophysics-for-ml-students`)
  > "That translation is imperfect, but it is enough to orient yourself." (same)

- **Explicit "why this matters" framing** that connects mechanics to stakes (LIGO/JWST/cosmo sims):
  > "You NEED to understand numerical methods at a fundamental level – not just which buttons to push, but why algorithms succeed or fail." (`mod1-overview`)

- **Multiple reading paths offered up front** (Fast Track / Standard / Deep) via grid cards (`mod1-overview` "Choose Your Learning Path"), and "read this first" / "read this once" orientation lines:
  > "Read this once and the rest of the system explains itself." (`brain/guide/mental-model`)
  > "Read it first if you are new to the package." (`progenax/ic-philosophy`)

## 3. Connecting topics: dense, deliberate cross-linking + "everything is coupled"

- **Inline MyST xrefs to the canonical home of each concept**, rather than re-explaining — e.g. linking to `[gravitational energy]`, `[Theory]`, ADR refs `{ref}`adr-0008-…``. (`timescales`, `brain/guide/mental-model`)

- **She links *and* tells you why you'd follow the link** ("a good next step is X if you want a first model, or Y if you want the equations first"):
  > "You are now ready for the more formal parts of the site. A good next step is [**Getting Started**] for a first model, or [**Theory**] if you want the equations first." (`from-physics-to-solver-to-inference`, Bridge block)

- **A recurring conceptual through-line: nothing is local / everything is coupled** — she connects topics by tracing a causal chain:
  > "Increase the opacity in the envelope, and the temperature gradient steepens. That shifts the boundary between radiative and convective zones. The convective zone changes the surface temperature… Nothing is local." (`stellar-astrophysics-for-ml-students`)

- **Tables used as cross-concept translators** ("ML concept ↔ stellar astrophysics analogue"; "Traditional Approach ↔ Research Reality"; term-glossary tables). (`stellar-astrophysics-for-ml-students`, `why-astr596-is-different`, `brain/guide/mental-model`)

## 4. Sentence rhythm & diction

- **Active voice, second person, direct address.** "You do not fit them. You look them up." (`stellar-astrophysics-for-ml-students`). "You're about to discover…" (`mod1-overview`).
- **Deliberate sentence-length variation for emphasis**: a run of medium sentences punctuated by a very short hammer. "A dense core occupies little volume. A tenuous envelope occupies a lot." / "Nothing is local." / "A main-sequence star does neither." (`stellar-astrophysics-for-ml-students`)
- **Parallelism / triads** as a structural device: "state variables, source terms, transport laws, and boundary conditions"; "the physics is one codebase, the fitting procedure is another, the sensitivity study is manual…" (`from-physics-to-solver-to-inference`)
- **Low hedging in explanation; precise hedging where honesty requires it.** She states things plainly ("The forward pass is solve the star") but flags uncertainty explicitly when she can't verify: "I'm naming the body of work, not specific papers I can verify by memory. Treat these as starting points for literature review, not definitive citations." (`sophie/pedagogical-foundations`)
- **Bold for the load-bearing term/pivot, italics for emphasis or for the reader's mistaken assumption.** Term-introductions are bolded on first use ("**enclosed mass** $m$", "**constitutive physics**"). (`stellar-astrophysics-for-ml-students`)
- **Intuition-before-math is the default ordering**: physical picture first, then the closed-form, then a worked solar number. (`timescales`, `stellar-astrophysics-for-ml-students`)

## 5. Quantitative anchoring (a strong, consistent fingerprint)

Even in "explanatory" prose she anchors abstractions to **real numbers in CGS / solar units**, and frequently a "For the Sun:" sanity-check:

> "At the Sun's center ($\rho \sim 150$ g/cm$^3$, $T \sim 1.57 \times 10^7$ K), the gas is nearly ideal." (`stellar-astrophysics-for-ml-students`)
> "**For the Sun:** $t_{\rm dyn} \approx 27$ minutes." (`timescales` — every timescale gets a "For the Sun:" line)
> "The present-day Sun is $\sim$30% more luminous and $\sim$10% larger than its ZAMS counterpart." (`common-misconceptions`)

Scaling relations are written with explicit power-law dependences and fiducial normalizations, and "dynamic range" tables (center vs surface vs ratio) are a recurring device. (`timescales`, `stellar-astrophysics-for-ml-students`)

## 6. Structure habits

- **MyST admonitions are a core voice element, used with consistent intent:**
  - `:::{aside}` — route a different audience / give an optional deeper note (very frequent in stellax/brain).
  - `:::{note} What We Just Learned` — a recap block closing a conceptual page. (`from-physics-to-solver-to-inference`)
  - `:::{warning}` — a draft-status banner *and* an anti-pattern flag ("Don't duplicate code…", "Don't fabricate"). (`brain/guide/staying-lean`)
  - `:::{note} **TL;DR:**` with `:class: dropdown` — collapsible executive summary at the top of long course pages. (`why-astr596-is-different`)
- **Custom interactive callouts in course/stellax prose** rendered as blockquotes with emoji labels:
  > "> 🤔 **Quick Check** … > 🌉 **Bridge** … :::{note} What We Just Learned" (`from-physics-to-solver-to-inference`)
  (These three — Quick Check, Bridge, What We Just Learned — recur as a pedagogical scaffold.)
- **Numbered/named conceptual units** rather than bare headings: "The four physical questions", "The three constitutive ingredients", "Three things every progenax IC fixes" — she counts the pieces and tells you the count first.
- **Rich tables**: translation tables, comparison tables, `{list-table}`/`{grid}` directives, and the "For the Sun" comparison tables.
- **Math placement**: display equations carry MyST labels (`(eq:t-dyn)`) for cross-reference; each equation is sandwiched by a plain-language reading of what it *measures* before and a numeric instantiation after.
- **Frontmatter discipline**: `title` + `subtitle` + `description` (the subtitle is itself a one-line thesis, e.g. "Three clocks that govern stellar life"); explanatory pages carry provenance/status fields (`status: draft`, `last_audited`, `confidence: source-backed`).

## 7. Tone: warm, direct, intellectually honest, lightly playful

- **Encouraging without being soft** — names the difficulty, then reassures: "The good news is that the central ideas are not exotic." (`stellar-astrophysics-for-ml-students`); "make interdisciplinary entry feel welcoming instead of remedial" (her own FIGURE-SUGGESTION note, same page).
- **Memorable, slightly pugnacious one-liners** carry the message: "elegant nonsense is still nonsense." (`from-physics-to-solver-to-inference`); "a hub you can't trust is a hub you stop using." (`brain/guide/staying-lean`); "Every knowledge system dies the same death." (same).
- **Honesty as a stated value, not just a behavior** — she calls out where she's inferring vs. citing, and bakes "no fabrication" into the prose itself. (`sophie/pedagogical-foundations`, `brain/guide/staying-lean`)
- **Restrained, purposeful humor / vividness**: "spheres of glowing gas" that turn out "surprisingly nasty" numerically (`stellar-astrophysics-for-ml-students`); "Mazur's Peer Instruction with a fresh coat of paint" as a quality bar (`sophie/pedagogical-foundations`). Emoji appear as *functional* labels (🤔 🌉 🎯), not decoration.
- **Motivational claims are evidence-cited**, not hand-waved: she backs pedagogy with named literature (Schwartz 2008, Ting & O'Briain 2025, Tetlock, Dunlosky/Rawson). (`why-astr596-is-different`, `sophie/pedagogical-foundations`)

## 8. Anti-patterns her good pages avoid

Inferred from the consistent positive practice above (and from her explicit "anti-patterns" sections):

- **Never opens cold with a formal definition or a wall of equations** — always a hook/reframe/question first.
- **Never leaves a concept abstract** — there is almost always a number, a "For the Sun," or a concrete causal chain.
- **Never lets an analogy stand unbounded** — she states its limits in the same breath ("That translation is imperfect…").
- **Never conflates "it ran / it converged / it's elegant" with "it's correct."** A whole page exists to attack this: "Convergence means validation" is Misconception #1; "elegant nonsense is still nonsense." (`common-misconceptions`, `from-physics-to-solver-to-inference`)
- **Never fabricates a citation or a connection** — flags inferences explicitly; "No documented connection found" beats an invented link. (`brain/guide/staying-lean`, `sophie/pedagogical-foundations`)
- **Never assumes one audience** — layered asides and explicit reading paths instead of a single pitch level.
- **Never buries the stakes** — "why this matters" is surfaced, not assumed.

---

## Thin-corpus caveats (be honest about coverage)

- **Humor** is present but *restrained*; the sample shows wit and vivid phrasing more than jokes. Don't over-rotate toward comedy.
- The **interactive scaffold blocks** (🤔 Quick Check / 🌉 Bridge / What We Just Learned) are strongly attested in `stellax` foundations and ASTR596 course prose, but are *not* universal — the terse internal `brain/guide` reference pages and the `progenax` theory pages mostly omit them. Use them for *teaching* pages, not every reference page.
- **Reference-type pages** (e.g. `brain/guide` reference, `progenax` definition pages) are terser and more definition-forward than the foundations/course pages — the "hook-first" rule relaxes for pure reference material, though even there she opens with an orientation sentence ("Read this once…", "Read it first if you are new…").
- Pages flagged `status: draft` in stellax sometimes carry her own `<!-- FIGURE SUGGESTION -->` author-notes; these reveal intent (e.g. "make interdisciplinary entry feel welcoming instead of remedial") but are not published prose.
