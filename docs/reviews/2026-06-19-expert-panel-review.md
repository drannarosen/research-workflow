# Simulated expert-panel review — research-workflow v1.5.0
*2026-06-19 · 6 personas (academics + techbros) · simulated, opinionated, deliberately critical*

Scope reviewed: 70 skills / 8 deterministic hooks / 6 commands / 1 verifier agent; the partition-lint
discipline; HITL-enforcement philosophy (ADR-0001); equation-provenance & figure-craft layers; the
modular-vs-merge / flagship-marketplace decision.

## 🎓 Prof. Diane Okafor — senior computational astrophysicist (target user)
"Finally, someone encoded the things I yell at my grad students about."
- The epistemic-integrity cluster (`ai-self-distrust`, `null-result-integrity`, `adversarial-result-check`, `systematic-error-hunting`) is the real contribution — the actual failure mode of AI-assisted research, ungated elsewhere.
- `equation-to-code-traceability` + `reference-license-firewall` + PDF verifier: the unglamorous stuff that sinks papers (a sign error from a two-column OCR).
- Skepticism: does the model *obey* 70 advisory skills under deadline, or just the 8 hooks? You've gated completion *claims*, not shown the *advice* changes behavior. Show a before/after.
- **8/10 — best research-rigor tooling seen; unproven it's used as intended.**

## 🔬 Dr. Sam Reinholt — research software engineer / reproducibility (US-RSE)
"The hooks are the thesis; the skills are the marketing."
- Deterministic hooks over prompt-enforcement (ADR-0001) is correct and under-appreciated. 60-case hook suite + shellcheck + `claude plugin validate` in CI = real hygiene.
- The partition lint (`## Related` + negative-trigger required by CI) is the smartest thing here — most skill collections are soup; this one fails CI if a skill doesn't say where it stops.
- Concern: the skills have no behavioral tests (you own `testing-skills-with-subagents` — is it run on these 70?). `RWF_HOOK_DEBUG` logging is admitted a *lower bound*. Measuring gates, not advice. Sustainability: one maintainer, 1.2→1.5 in a day.
- **8.5/10 on craft, incomplete on evidence-of-efficacy — ironic for an evidence-first plugin.**

## 📊 Dr. Wei Chen — Bayesian methodologist (skeptic)
"Love `mcmc-convergence-gate`. Worried it becomes a checklist amulet."
- R-hat<1.01 (Vehtari 2021), bulk/tail ESS, divergences→reparameterize: correct and current. `predictive-checks` prior-vs-posterior split is right.
- Risk: rigor-as-vocabulary → rigor *theater* (model name-drops "checked R-hat" without the diagnostic clearing). Hooks can't catch that; only a numeric artifact can.
- Where's the gate that a posterior summary doesn't ship without diagnostics *attached as output*? That should be a hook, not a skill.
- **7.5/10 — methodologically sound, one gate short of teeth.**

## 🚀 Marcus Vance — YC-style founder
"70 skills is either a moat or a closet nobody opens. Which is it?"
- Flagship-brand-not-merge call was right; didn't bloat the namespace to chase installs.
- But who's the user? Exquisitely tuned to one astrophysicist (jaxstroviz, CGS, MESA/REBOUND lenses, Anna's docs voice). "Domain-agnostic" is in the README, not the artifact. Admit it's a power-tool for ~500 computational scientists; don't cosplay TAM.
- The wedge is `equation-digest` + `reference-license-firewall` — that's a *product*. Ship it standalone; the other 66 are a personal OS.
- **Real craft, unclear GTM. Pick: personal exocortex or product. Both is a trap.**

## ⚙️ Priya Nair — devtools/DX engineer (ex-FAANG)
"What's the token bill on loading 70 skill descriptions every session?"
- Clean architecture: hooks-as-middleware, deferred tool schemas, co-located references. `(→ sibling)` arrows that resolve in CI is a great invariant.
- Worry: activation surface — 70 descriptions = latency, tokens, mis-trigger probability rising with N. Routing tests were ~10 queries/batch = anecdote, not a regression suite. Where's automated routing-collision CI?
- Hooks are regex-based; your own memory records two false-allow bugs in the evidence gate. Regex enforcement is a treadmill against a creative model.
- **8/10 — best-engineered skill pack seen; needs an observability/eval harness before it scales past its author.**

## 🤖 "devinthewild" — AI-agent indie hacker (vibes seat)
"An AI wrote a 70-skill plugin to stop AIs from writing slop. That's a koan."
- Most self-aware thing here: `ai-self-distrust`, figure-interpretation's "distrust a vision model reading a plot," the honest "lower bound" admission. Dogfoods its own paranoia.
- Teeth: assumes the same model that needs 70 guardrails will reliably read/follow 70 guardrails. Hooks survive that (deterministic); skills are a vibe. Skip the skill under pressure → the advisory 90% is Schrödinger's rigor.
- Gorgeous over-engineering; half your users will install it and use `/review`. The long tail is for you.
- **Ship it, it's art — but the gap between "skills exist" and "skills fire" is the whole ballgame.**

## 🧑‍⚖️ Consensus

**Unanimous praise:** (1) partition discipline enforced in CI — what makes 70 skills not-soup; (2) deterministic hooks > prompt enforcement (well-tested); (3) intellectual honesty baked in (ai-self-distrust, "lower bound" caveat, jaxstroviz self-critique).

**Headline concern:** you've rigorously verified the *gates* and barely verified the *advice*. 8 hooks enforced/tested; 62 skills advisory with no evidence they change behavior under pressure, and skill-logging admits it's a lower bound. For an evidence-first plugin, that's the missing experiment.

**Top 5 action items:**
1. **Skill-efficacy eval** — apply `testing-skills-with-subagents` to a sample (RED/GREEN: does the skill change output on a tempting failure case?). Ship the pass rate. *The missing experiment.*
2. **Promote one methodologist gate to a hook** — block a posterior summary in the final message that lacks R-hat/ESS in the turn's output. Amulet → teeth.
3. **Automate routing-collision CI** — turn ad-hoc query tests into a fixture suite so skill #71 can't silently overlap.
4. **Own the scope honestly** — drop "domain-agnostic" or back it; it's an astrophysics power-tool with thin general bones. (Or extract `equation-digest` as the standalone wedge.)
5. **Hook robustness** — regex gates have a false-allow history; add adversarial fixtures like the `interactive.mjs` injection ones.

**Closing (Okafor):** "Best-argued, best-engineered research-rigor plugin any of us has seen — and it will remain a hypothesis until you run the one experiment it keeps telling everyone else to run: show the evidence that the advice works."
