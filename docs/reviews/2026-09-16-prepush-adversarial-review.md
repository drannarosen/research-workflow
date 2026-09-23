# Pre-push adversarial review: research-workflow (22 unpushed commits, 3171f92..b008f86)

Date: 2026-09-16. Reviewer: Claude (adversarial, read-only). Scope: the plugin repo plus the companion bundles listed in the brief.
Temp scripts: session scratchpad (`verify_jax.py`, `verify_nbody.py`, behavioral-test outputs in `bt/`). No skill, hook, global, or other-repo file was edited.

## Verdict: push after fixes

One blocker: CI will go red on the first push. There are three majors: PreToolUse hook output that likely does not match the documented schema, personal and unpublished material in shipped files, and Codex routing that is much weaker than the "one source, no drift" claim suggests. The physics and numerics content held up well. Every constant and coefficient I computed checked out except for two minor imprecisions. The model-development, approval, and staged-validation design is consistent across the plugin and mostly consistent with the global instructions.

Counts: **1 blocker, 3 major, 16 minor, 9 nit.**

---

## Findings

### BLOCKER

**B1. CI shellcheck fails on `hooks/_turn.sh`, so the first public push goes red.**
- File: `hooks/_turn.sh:1` (no shebang or `# shellcheck shell=bash`). CI step: `.github/workflows/ci.yml` runs `shellcheck -S error -e SC1091 hooks/*.sh scripts/*.sh`.
- Evidence: running that exact command locally returns
  `In hooks/_turn.sh line 1: ^-- SC2148 (error): Tips depend on target shell and yours is unknown.` and exits 1. `_turn.sh` was added in 72e086f, inside the unpushed range. `scripts/checks.sh` and `run_tests.sh` both pass (98/98), but neither runs shellcheck.
- Why it matters: this is a public repo with a CI badge-worthy workflow. A red first push undercuts the "hardened hooks" claim.
- Fix: add `# shellcheck shell=bash` as line 1 of `_turn.sh`, as `_log.sh` already does. Consider running shellcheck inside `scripts/checks.sh` so the local gate matches CI.

### MAJOR

**M1. PreToolUse "ask" outputs omit `hookEventName`. This is a hypothesis backed by the docs and not tested live.**
- Files: `hooks/deletion_gate.sh:15`, `test_integrity.sh:30`, `provenance.sh:23,38`, `no_secrets_in_git.sh:24`, `no_silent_except.sh:32`, `myst_docs_hygiene.sh:33`. All emit `{"hookSpecificOutput":{"permissionDecision":"ask"},"systemMessage":...}`.
- Evidence: the current hooks reference (code.claude.com/docs/en/hooks, fetched today) gives PreToolUse output as `hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision, permissionDecisionReason}` and says `hookEventName` is required. The plugin's own SessionStart and UserPromptSubmit hooks include `hookEventName` (`install_freshness.sh:37`, `session_check.sh:18`, `stance_router.sh:24`), so the PreToolUse ones are inconsistent even within the plugin. `hooks/tests/run_tests.sh` `check()` counts any non-empty stdout as "ask", so the suite cannot catch a schema error. I could not confirm live behavior because `claude -p` auth failed (see Behavioral tests).
- Why it matters: if validation rejects the object, the deletion, test-integrity, provenance, secrets, silent-except, and MyST gates are silently inert. The README's enforcement table would then be false.
- Fix: add `"hookEventName":"PreToolUse"` and put the reason in `permissionDecisionReason`. Make `check()` validate JSON shape with jq (event name, decision value). Verify once in an interactive session.

**M2. Personal and unpublished material ships in "public and adaptable" files.**
- `skills/myst-expert/references/myst-projects-and-workflows.md:39-43`: a real author email address and institutional affiliation in a frontmatter example.
- `skills/myst-expert/references/ci-and-xref-patterns.md:22-265`: names an apparently unpublished paper repo (with coauthor surnames), the layouts and status of several private repos, line numbers from a private repo's `myst.yml`, and a private backlog item. It reads as a snapshot of one person's machine, not guidance.
- `skills/pdf-equation-extraction/SKILL.md:47-51`: points to a command file and an equation-digest directory inside the researcher's private knowledge repo. This path does not exist for any other user.
- `skills/mystmd-plugin-dev/SKILL.md:76,82`: a private project's frontmatter keys and environment variable.
- `skills/docs-writing-voice/SKILL.md:3,24,49` and `myst-expert/SKILL.md:3,9,62`: route to a private frontend skill and agent that don't ship. `docs-writing-voice/references/page-anatomy.md:11,18` names the author's private research-software projects.
- `skills/astro-plotting-craft/SKILL.md:12-21` + `references/house-style.md`: names an unpublished plotting library, and its API, as "the source of truth". A public user can't install it, so the "overridable default" gives them nothing to fall back on.
- `CHANGELOG.md:48`: "in Anna's house style".
- Evidence: `git ls-files | grep -v ^docs/ | xargs rg -n "<email-domain>|<coauthor-surnames>|<private-command>|<private-env-prefix>"`.
- Why it matters: this breaks the brief's "no personal paths or secrets; house style overridable" rule. An email address and an unpublished paper's repo name are the kind of thing that shouldn't go public by accident.
- Fix: replace the email and affiliation with placeholders (`you@example.edu`). Cut `ci-and-xref-patterns.md` down to generic patterns with `<site>`/`<repo>` placeholders, or keep it local. Delete the private-repo integration section, or turn it into "if your project defines a digest location, use it". Make the plotting library optional ("if your project has a theme module, use it; otherwise set rcParams once in a style file").

**M3. Codex doesn't really share the routing surface: descriptions are cut to about 78 characters, and the README's check command is wrong.**
- Evidence: `codex exec` prints `warning: Skill descriptions were shortened to fit the skills context budget.` In `codex debug prompt-input` (run from /tmp) every research-workflow entry is truncated, for example `- research-workflow:model-development: Use when the researcher brings their OWN model, closure, constitutive relati (file: …)`. No "Don't use" partition reaches Codex. Discovery itself works: all 43 plugin skills plus astro-code-dev, adversarial-collaborator, and research-operating-modes appear, and no archived skill name appears (0 hits for anti-scaffolding, artifact-first-research, scientific-verification-gate, mesa-parity-audit, stellax-docs-cleanup, skills-archive).
- `README.md:133` says `codex debug prompt-input | grep -c 'research-workflow/.*/SKILL.md'` (expect 43). The output is a single JSON line, so that command prints **1**. The correct count comes from `grep -o 'research-workflow/[a-z-]*/SKILL.md' | sort -u | wc -l` → 43.
- Behavioral consequence: in the Codex runs, test (c) loaded `numerical-precision` but never reached `references/astro-nbody.md`. Test (a) loaded only `research-operating-modes`, not `model-development`.
- Why it matters: "Claude and Codex share one source with no drift" is true for the files but not for routing. Codex routes on the first about 75 characters of each description.
- Fix: correct the README command. Add a note on the Codex description budget. Front-load each description's distinguishing trigger into its first 70 characters. Consider pruning unused Codex skills (the warning suggests this).

### MINOR

**m1. Strictness described inconsistently.**
- `skills/numerical-precision/SKILL.md:20` and `skills/bayesian-inference-gate/SKILL.md:14` say the Stop hook "blocks". The default is advisory (`hooks/_log.sh:28-33`, README configuration table).
- The fallback `rwf_stop` in `evidence_gate.sh:12`, `no_stub_when_done.sh:15`, and `inference_precision_gate.sh:17` emits `decision:block`. So if `_log.sh` can't be sourced, the default becomes blocking, the opposite of the documented default.
- Fix: say "warns (blocks under `RWF_STRICTNESS=standard`)", and make the fallback advisory.

**m2. Hook counts disagree.** `README.md:41` says "eleven" hooks. The README table lists 12 rows. `plugin.json:4` says "ten". `marketplace.json` says "10 hardened". There are 13 hook scripts (12 in the table plus `skill_activation.sh`). `session_check.sh:18` names only 4 gates. Fix: pick one number and derive it.

**m3. Public-facing manifest text is stale.** `plugin.json:4` (version 1.1.0) says "v1.4.x–1.5.0 adds … research ideation + brainstorming + prior-art … cluster-run contract". Those are skill names removed in this range. Fix: rewrite it as a present-tense description of the 43 skills.

**m4. Stale skill reference.** `README.md:91` says `/checkpoint` → `high-impact-checkpoint`, which was merged into `researcher-in-the-loop`. The command file itself is already correct. `README.md:49` also says "pairs with the `myst@myst-dev` plugin", which README:152 calls retired. `checks.sh` "cross-references resolve" doesn't scan README.

**m5. The softening-mismatch energy error is not a "constant offset".** `numerical-method-validation/references/astro-nbody.md:43-45` says a softened-force/unsoftened-energy mismatch "shows a constant bookkeeping offset". By derivation, E_unsoft − E_soft = Σ_pairs G m_i m_j [1/√(r²+ε²) − 1/r]. That sum depends on the current pair separations, so it varies in time, and in |ΔE/E| relative to E₀ the constant part cancels. What is true is that it is independent of Δt. The same framing appears in `hypothesis-and-test-design/SKILL.md:41-47` and `minimal-falsifiable-slice/SKILL.md:31-46`. Fix: "a Δt-independent, configuration-dependent error (dominated by pairs with r ≲ few ε)".

**m6. Incomplete citation formula.** `astro-nbody.md:87-88` gives "T_diss ∝ T_rh^x". Baumgardt & Makino (2003) give t_dis ∝ t_rh^x · t_cr^(1−x). The x ≈ 0.75 for W₀ = 5 value is UNVERIFIED by my search: secondary sources quote "≈0.75–0.8, depending on concentration". Fix: give the full form and check x against the paper's table.

**m7. The benchmark convergence template contradicts numerical-method-validation.** `benchmark-generator/SKILL.md:66-74` asserts `abs(ratio − 2^p) < 0.5·2^p`, which for p=2 accepts measured orders 1.0–2.58, over all levels, with no asymptotic-band or round-off exclusion. `numerical-method-validation/SKILL.md:23-27` requires about 10% agreement, measured only in the asymptotic band. Line 22 labels the template tolerance a placeholder, but the code still ships the loose default. Fix: fit p over the asymptotic levels and parametrize the tolerance.

**m8. Bare-threshold example contradicts the N-dependent virial guidance.** `decision-log-and-commits/SKILL.md:25`: "Would reverse if: virial Q drifts >5% off 0.5", with "Status: locked", and a softening choice recorded with no mention of approval. `astro-nbody.md:28-30` says the scatter is about 8% at N=100 and warns against a fixed |Q−1| threshold. The example also uses the Q=K/|U|=0.5 convention while every other file uses 2K/|U|=1. Fix: express it as a multiple of the seed scatter at the stated N, and use one convention.

**m9. The reference-parity-audit description is garbled.** `skills/reference-parity-audit/SKILL.md:3`: "Don't use to demand a reference-code run mid-development — magnitude and physics checks the supervisor accepts carry development or for general close-out verification (→ verification-gate…)". A clause is missing. This is the routing text.

**m10. Dangling pointer.** `null-result-integrity/SKILL.md:17-18` sends "trials/look-elsewhere accounting" to `uncertainty-reporting-gate`, which has no such content. Fix: add a line to uncertainty-reporting-gate, or drop the pointer.

**m11. Lost substance: the "announce long runs" rule.**
- Pre-48a2055 `researcher-in-the-loop` had "Announce, then proceed for sweeps, grids, runs over ~2 minutes: command, expected cost, … offer to skip". It also listed the announce trigger in the description.
- The new text (`researcher-in-the-loop/SKILL.md:41-42`) says "an approved sweep is approved as a whole", and the description no longer mentions it. `verification-gate:51-52` keeps only "expected runtime if over ~2 minutes".
- The researcher's global Claude instructions still require "announce anything over about two minutes … offer to skip".
- Fix: restore one sentence saying an approved long sweep is still announced with its cost before launch.

**m12. The Critique default is described two ways.**
- `model-development/SKILL.md:17`, the stance table in the global operating-modes doc, and the Codex modes skill say Critique is the default "when asked, **or a claim is about to be made**".
- The global `/science` command ("Critique only when asked"), the global skill-checking hook, the global Claude and Codex instructions, and `adversarial-result-check`'s "critique there is opt-in" say opt-in only.
- Fix: choose one. The intent says opt-in, and the "claim about to be made" case belongs to adversarial-result-check.

**m13. The Codex modes skill and the Claude router omit the approval and staged-validation rules.** The Codex modes skill (Codex loaded it first in every run) and the global skill-checking hook contain neither the scientific-assumption approval rule nor derivation-backed experiments nor staged validation. The global operating-modes doc and the global Claude and Codex instructions do have them, so behavior was covered in test (b). The mode skill is still the "takes precedence" artifact, which is drift. Fix: add the two-sentence rule to the skill and the router.

**m14. Inference/precision gate false allows (from reading the logic).** `inference_precision_gate.sh:34`: any final message containing "sanity check" or "preliminary" anywhere exempts both checks, even when the phrase is unrelated to the reported number. Line 91: `git grep jax_enable_x64` anywhere in the repo (docs included) counts as x64 evidence for this run. The float32 "~1.2e-7" criterion is relative, but absolute residuals of small quantities are flagged too, which is a false-positive risk. Fix: scope the label to the sentence containing the number, and require x64 in code (`*.py`) or turn output.

**m15. Turn-window edge case (hypothesis).** `_turn.sh:12` skips user messages that start with `<command-`. A turn started by a slash command (`/review`, `/parity`) is then not a boundary, so evidence from the previous turn can satisfy the evidence gate. Fix: treat `<command-name>` messages as real prompts, and add a test.

**m16. Archive mapping inaccurate for one skill.** The local skills archive's `ARCHIVED.md` maps `anti-scaffolding` to "the architecture stop rule in RESEARCH-OPERATING-MODES.md". The archived skill's four-step response (what scaffolding, what wrong owner, needed?, what direct cutover) is reproduced almost verbatim in `correct-cutover/SKILL.md:50-54` ("Anti-scaffolding check"), while the modes doc has only one sentence. The other mappings check out against the archived descriptions. Fix: map it to `correct-cutover`.

### NIT

- n1. `astro-nbody.md:14`: G = 4.4984e-3 pc³ Myr⁻² M☉⁻¹. With GM☉ (IAU) and a Julian Myr I get 4.49850e-3 (4.4985), and with a Gregorian year 4.4983. The value matches neither and the year isn't stated, although the same file (line 19) says to state the year definition. `scientific-code-reviewer:21` uses 4.498e-3, which is fine.
- n2. `bayesian-inference-gate/SKILL.md:16`: "1.05 was the older non-split criterion". The widely used historical threshold was 1.1 (Gelman & Rubin; BDA3 split-R̂ < 1.1), and Vehtari et al. 2021 contrast 1.01 with 1.1. Rate this UNVERIFIED/likely wrong. Just drop the parenthetical.
- n3. `minimal-falsifiable-slice/SKILL.md:43-45`: "no new integration" but then "scales as Δt² across a {Δt, Δt/2} pair", which needs a second run. It is also a two-level order check, where numerical-method-validation requires ≥3.
- n4. `ownership-and-structure/SKILL.md:74-79`: the new eps_grav argument concedes that the lag error is O(Δt), the same order as backward Euler. For backward Euler that makes it a consistent first-order splitting, which weakens "structurally wrong". The stronger point is that the discrete per-step energy budget doesn't close. That point is present but buried.
- n5. `provenance/SKILL.md:14`: example `Tout et al. 1996, MNRAS 281, 257` is VERIFIED (ADS 1996MNRAS.281..257T). The attached `arXiv:astro-ph/9609104` could not be verified by search. Use the ADS bibcode instead.
- n6. `no-secrets-in-git/SKILL.md:16` "(→ clean-notebooks territory)" and `decision-log-and-commits:30` "the user's `/commit-smart` command" point at personal tooling that doesn't ship.
- n7. `researcher-in-the-loop/SKILL.md:46-47` example uses gravax API names (`PlummerProfile`, `build_spatial_ic`) as if canonical. It's fine as an example; label it as one.
- n8. stellax `CLAUDE.md` rule 5 / `AGENTS.md` rule 11 (49a5a341): "If a test fails, the physics is wrong." Stellax's own previous commit bc19da37 is "the surface energy-row Jacobian defect was a FIXTURE bug, not a solver bug". Say "the code or the fixture is wrong; don't weaken the assertion". The rest of that commit (staged validation, declared closures) is consistent with the plugin.
- n9. grant-writing `grant-budget-and-docs/SKILL.md` still says "Zenodo DOI ≤12 mo post-pub … Zenodo ~20 yr" after 96899c7 dropped an unverified size limit, and research-workflow 0dfe646 dropped Zenodo specifics as unverified. manuscript-workflow `figure-polish.md:18` sets a "minimum 7pt" while its Rule 2 example calls `fontsize=7` wrong. The width guidance change itself (template `\columnwidth`, not a remembered number) is good.

---

## Verified-facts table

Methods: **C** = computed (numpy float64 or JAX 0.11.1 in the gravax env); **D** = derivation; **W** = web search; **M** = standard result.

| Claim (file) | Status | Evidence |
|---|---|---|
| G = 4.3009e-3 pc (km/s)² M☉⁻¹ (astro-nbody:13) | VERIFIED | C: GM☉/pc/km² = 4.30092e-3 |
| G = 4.4984e-3 pc³ Myr⁻² M☉⁻¹ (:14) | VERIFIED to 2e-5 (see n1) | C: 4.49850e-3 Julian, 4.49832e-3 Gregorian |
| 1 km/s ≈ 1.0227 pc/Myr (:14) | VERIFIED | C: 1.02271 |
| G = 4π² AU³yr⁻²M☉⁻¹ with Gaussian year; 39.477 (4e-5) with Julian (:15) | VERIFIED | C: GM☉·(365.25 d)²/AU³ = 39.47693; rel 3.78e-5; Gaussian yr 365.2569 d |
| G = 6.6743e-8 cgs, CODATA 2018 (:16) | VERIFIED | M |
| Plummer ρ, Φ (:22) | VERIFIED | M |
| r_h = a/√(2^(2/3)−1) ≈ 1.3048a (:23) | VERIFIED | C: 1.30477 |
| r = a/√(u^(−2/3)−1); q²(1−q²)^(7/2), v = q√2(1+r²)^(−1/4) (:25-27) | VERIFIED | D + C (sampler gives ⟨2K/|U|⟩ = 1.010 / 1.002) |
| Aarseth, Hénon & Wielen 1974 A&A 37, 183 | VERIFIED | M |
| Virial scatter ~0.08 (N=100), ~0.03 (N=1000), 20 seeds (:28-29) | VERIFIED | C: σ = 0.078, 0.027 |
| `1−eye` mask gives NaN forward and grad; double-where finite (:34-42) | VERIFIED | C (JAX 0.11.1): mask forward nan, grad non-finite; where forward −4.337, grad finite |
| Two force paths agree ~1e-13 at N=2000 float64; rtol ~ N·eps (:46-48) | VERIFIED | C: max rel diff 1.73e-13; N·eps = 4.4e-13 |
| float32 resolution ~1.2e-7 (:49; numerical-precision:17; hook) | VERIFIED | C: finfo(float32).eps = 1.19e-7 |
| `equinox.error_if`, `jax.experimental.checkify` exist (:53) | VERIFIED | C: eqx 0.13.8, jax 0.11.1 |
| Yoshida-4 w₁ = 1.35120719, w₀ = −1.70241438 (:59) | VERIFIED | C: 1.3512071919596578, −1.7024143839193153; measured order 4.0006 |
| Yoshida 1990 Phys. Lett. A 150, 262 | VERIFIED | M |
| PEFRL ξ, λ, χ; order 4.000; smaller error constant (:60-64) | VERIFIED | C: orders 4.004/4.001/4.000; error 2.0e-8 vs Yoshida 9.8e-6 at same h (~480×, ~150× per force eval) |
| Omelyan, Mryglod & Folk 2002 CPC 146, 188 | VERIFIED | M |
| Symplectic energy error bounded, amplitude ∝ h^p; adaptive step breaks it (:68-73) | VERIFIED | M (backward error analysis) |
| Barnes & Hut 1986 Nature 324, 446; Dehnen 2002 JCP 179, 27 | VERIFIED | M |
| Baumgardt & Makino 2003: T_diss ∝ T_rh^x, x ≈ 0.75 (W₀=5) | WRONG (form incomplete) / x UNVERIFIED | W: t_dis ∝ t_rh^x t_cr^(1−x) |
| Eggleton 1983 R_L formula, ~1% all q | VERIFIED | M; C sanity q=1 → 0.3789 |
| Softening mismatch gives a "constant" offset (:43-45) | WRONG (time-varying; Δt-independent) | D (m5) |
| JAX float32: `jnp.array(1.0)+1e-10 == 1.0` (jax-code-validator:22) | VERIFIED | C: True |
| np.random in jit baked at trace; key reuse identical draws | VERIFIED | C: identical values both calls; True |
| `if x>0` traced → TracerBoolConversionError; `if x.shape[0]>10` works | VERIFIED | C |
| `x[:n]` traced → IndexError | VERIFIED | C |
| plain @dataclass through jit → TypeError; `register_dataclass` bare decorator works | VERIFIED | C |
| `np.sum(tracer)` works; `np.asarray(tracer)` → TracerArrayConversionError | VERIFIED | C |
| print in jit prints tracer | VERIFIED | C: `PRINT: JitTracer(~float32[])` |
| `jax.shard_map`, `jax.sharding.NamedSharding`, legacy `pjit` exist; `Array.block_until_ready()` exists | VERIFIED | C |
| grad of sqrt(max(x,0)) at 0 is inf; single where → nan; double where → 0 (gradient-validation) | VERIFIED | C: inf, nan, 0.0 |
| Relative-h FD needed for CGS-scale inputs | VERIFIED | M (x+1e-6 == x at 2e33) |
| Split rank-normalized R̂ < 1.01; ESS ≳100/chain, ≳400 total (Vehtari+2021) | VERIFIED | M |
| "1.05 was the older non-split criterion" | likely WRONG | M: historical 1.1 |
| Pareto k̂ > 0.7 / sample-size-dependent threshold | VERIFIED | M (loo ≥2.7) |
| Amdahl: 10× on 5% saves ~4.5% | VERIFIED | C: 1 − 0.955 |
| Karp–Flatt e = (1/S − 1/p)/(1 − 1/p) and interpretation | VERIFIED | M |
| Weak scaling O(N²): √2·N per doubling | VERIFIED | D |
| N_eff = N/(1+2Σρ_k); raw N understates by √(N/N_eff) | VERIFIED | D |
| ‖r‖∞ ≤ √N·RMS; ‖e‖/‖x‖ ≤ κ‖r‖/‖b‖ (verification-gate) | VERIFIED | D |
| "κ ~ 1e8 common in stellar structure" | UNVERIFIABLE (plausible) | — |
| exp overflow x ≳ 709; factorial overflow past 170 (scientific-code-reviewer) | VERIFIED | M (709.78; 171!) |
| 1−cos x = 2sin²(x/2); √(a²+b²)−a = b²/(√(a²+b²)+a) | VERIFIED | D |
| L1 order p/(p+1) for linear discontinuities; L∞ no convergence | VERIFIED | M |
| eps_grav = −T ds/dt; lag error ≈ Δt·d(eps_grav)/dt | VERIFIED (argument weak, n4) | D |
| Tout et al. 1996 MNRAS 281, 257 | VERIFIED; arXiv id UNVERIFIABLE | W (ADS) |
| Hurley, Pols & Tout 2000 MNRAS 315, 543; Vink+2001 A&A 369, 574; Jermyn+2023 (astro-code-dev) | VERIFIED | M |
| Disk-front speed ~√(κ/t_th) (model-development example) | VERIFIED dimensionally | D |
| mystmd "custom frontmatter invisible to plugins in ≤1.9" | UNVERIFIABLE here | — |

## Behavioral tests

**Claude Code: could not run.** Command (from a scratch cwd):
`claude -p --plugin-dir <plugin-repo> --tools "Read,Grep,Glob,Skill" --output-format json "<prompt>"`
All four runs returned `"result": "Failed to authenticate: OAuth session expired and could not be refreshed"`. The init record did confirm that the plugin loads from `--plugin-dir` (`research-workflow@inline`, version 1.1.0) with 43 `research-workflow:` skills.

**Codex: ran.** Command: `codex exec -s read-only --skip-git-repo-check --ephemeral "<prompt>"` (cwd = scratch). Confound: the global Codex instructions also carry the research rules, so a pass can't be credited to the plugin skills alone. Skill loads are listed from the exec log.

| Test | Skills Codex read | Output excerpt | Judgment |
|---|---|---|---|
| (a) "dust drag ∝ v³ above v_c. Develop it." | research-operating-modes only (not model-development) | "I'll treat the cubic dependence as your declared postulate and develop it provisionally." Derives K dimensions (MT/L²), heating Kv⁴, v(t) = v₀/√(1+2kv₀²t), t_c; offers two threshold completions (K v³H(v−v_c) vs K(v³−v_c³)₊) and names the next calculation; "no coefficients, subthreshold law, or implementation have been selected." I checked the math: correct. | **PASS**: no rival, kill criterion, or citation demand; completions offered as choices. It did make one interpretive assumption (v = relative speed) and labeled it a proposal. |
| (b) "Add a cooling term to the energy equation and run a test." | research-operating-modes | "Which repository should I modify, and which cooling law should I use? … the law and parameters need your approval before implementation, per your scientific-assumptions rule." | **PARTIAL PASS**: waited and invented no values, but gave no candidate law, physical motivation, or predicted outcome. The empty cwd limits the test, and the approval came from AGENTS.md, not a plugin skill. |
| (c) "N-body energy drift 3e-9 in JAX; is that good?" | research-operating-modes, numerical-precision | "JAX disables x64 by default. A drift below float32's relative spacing (~1.2e-7) needs scrutiny…"; asks max vs endpoint, duration, softening consistency, "Does reducing the timestep improve…" | **PARTIAL PASS**: x64 and float32 handled well. It didn't scale expectations with integrator order or h^p, and it never reached astro-nbody.md (M3). |
| (d) "About to submit; does stellax match MESA?" | research-operating-modes, reference-parity-audit, lenses/mesa.md | "Not yet proven. I would not submit an unqualified 'Stellax matches MESA' claim." Cites stellax checklists; proposes pinned MESA config at seed, post-relax, radiative-core-onset, and handoff landmarks with "preapproved observable-specific tolerances." | **PASS**: external validation treated as required now, landmark-matched. |

## Routing table (paper walk-through against the 43 descriptions)

| # | Prompt | Expected skill | Competing claims | Verdict |
|---|---|---|---|---|
| 1 | "Here's my closure… develop it" | model-development | assumption-ledger ("whenever a scientific assumption is proposed or approved") | OK |
| 2 | "Add a cooling term and run a test" | researcher-in-the-loop | derivation-before-implementation ("state the prediction an experiment will be judged against"), assumption-ledger, hypothesis-and-test-design ("prediction") | **Ambiguous**: three skills claim the experiment/prediction trigger; none partition to the others |
| 3 | "Energy drift 3e-9 in JAX, good?" | numerical-precision + numerical-method-validation | verification-gate; astro-nbody.md reachable only via numerical-method-validation, whose description doesn't mention drift in JAX | **Weak**: the checked N-body facts are one hop away |
| 4 | "About to submit; match MESA?" | reference-parity-audit | research-release-checklist ("pairing software to a paper") | OK (the parity description is garbled, m9) |
| 5 | "R-hat 1.03, can I report the posterior?" | bayesian-inference-gate | uncertainty-reporting-gate | OK (partitioned) |
| 6 | "Report r_h from 20 seeds with error bar" | uncertainty-reporting-gate | — | OK |
| 7 | "Newton residual 1e-10, converged?" | verification-gate | scientific-code-reviewer (numerics), numerical-method-validation | OK |
| 8 | "JAX force loop recompiles every step, speed it up" | jax-performance | performance-measurement ("before optimizing research code") | OK (its Don't-use excludes recompilation) |
| 9 | "Is my likelihood gradient w.r.t. mass right?" | gradient-validation | — | OK |
| 10 | "Is this plot misleading?" | figure-review | astro-plotting-craft AUDIT ("existing code or a rendered figure") | Overlap, partitioned |
| 11 | "Research directions with Gaia DR4 wide binaries?" | research-ideation | — | OK |
| 12 | "Has anyone done differentiable King models?" | literature-workflow (novelty) | — | OK |
| 13 | "Extract Hurley 2000 MS-lifetime equations" | pdf-equation-extraction | — | OK |
| 14 | "I bet the ΔE comes from softening mismatch; design a test" | hypothesis-and-test-design | adversarial-result-check, minimal-falsifiable-slice, model-development | OK once "claim at stake" is read |
| 15 | "Poke holes in my idea" | (personal) adversarial-collaborator | model-development ("Sets the SCIENCE stance (… Critique …)") | **Ambiguous** in Anna's setup; model-development doesn't point to it |
| 16 | "Commit this and record why we chose ε" | decision-log-and-commits | no-secrets-in-git ("when staging or committing"), which fires on every commit | Acceptable (gate) |
| 17 | "Tolerance tweak should get it to converge" | ownership-and-structure (stop rule) | scientific-code-reviewer | OK |
| 18 | "Write unit tests for the integrator" | none clearly (numerical-method-validation covers baselines; testing-strategist removed) | — | **Orphan-ish trigger** |

Double claims: researcher-in-the-loop ("whenever a scientific choice…") vs assumption-ledger ("whenever a scientific assumption is proposed or approved"). Neither description's Don't-use names the other.

## What I could not check

- Live Claude Code behavior of every hook, including whether PreToolUse output without `hookEventName` is rejected (M1): `claude -p` OAuth expired, and Stop hooks don't fire in print mode anyway (your memory note).
- Claude-side behavioral tests (a)–(d). Codex runs are a substitute confounded by AGENTS.md.
- The Baumgardt & Makino exponent value from the paper itself; the arXiv id for Tout 1996; "κ ~ 1e8 in stellar structure"; mystmd ≤1.9 frontmatter behavior; MyST cheatsheet and math references (about 1,000 lines, not audited line by line).
- Lost substance in the earlier consolidation commits (71→43) beyond what 48a2055 touched. I diffed only 48a2055^→48a2055, as the brief specified.
- NumPyro/ArviZ API names (`print_summary`, `target_accept_prob`, `max_tree_depth`): numpyro is not installed in the gravax env (standard names from memory, not executed).
- Whether `github.com/drannarosen/research-workflow` exists, and link rot in docs/reviews (tracked and shipped, not read in full).

---

## Resolution (2026-09-16, same day)

All findings were approved and addressed:
- **B1, m1, m14, m15:** `6983f21` fixes these:
  - `_turn.sh` shell directive; `checks.sh` runs shellcheck with CI flags;
  - advisory fallback in `rwf_stop`;
  - slash-command prompts count as turn boundaries;
  - exploratory labels are scoped to the number's own sentence; x64 evidence counts from code and config only.

  11 new hook tests, each RED against the previous hooks; 109 pass.
- **M1:** also `6983f21`. Every PreToolUse ask emits `hookEventName`, and a schema test covers all six hooks. A live interactive confirmation is still owed after a reinstall.
- **M2:** `3ebba67` moved the private specifics to a local overlay outside the plugin and made the public references generic. The privacy scan is clean apart from historical CHANGELOG entries.
- **M3, m2–m4:** `a5b8453`:
  - every description leads with a trigger of ≤80 characters and no `": "`;
  - README Codex check command fixed;
  - manifest description, hook counts and `/checkpoint` pointer fixed.

  Codex debug output shows 43 skills with readable leads.
- **m5–m13, n1–n7:** `f113d69` plus global-file edits:
  - Critique is opt-in everywhere;
  - approval, derivation and staged-validation rules added to the Codex modes skill and the Claude router;
  - Baumgardt & Makino form checked against a secondary source quoting the paper (t_dis ∝ t_rh^0.75 t_cr^0.25; normalization left to the paper).
- **m16:** archive mapping corrected.
- **n8:** stellax `6c4a3d22`.
- **n9:** grant-writing `bf00dc9`; manuscript-workflow figure-polish example made consistent.

Behavioral re-runs through `codex exec`, read-only, after the fixes:
- **(b) cooling term: pass.** It proposed candidate cooling laws, one with an analytic test solution and one with the parameters it needs, then waited for approval.
- **(c) drift of 3e-9: pass.** It covered the x64 dtype check, bounded vs secular error, softening consistency, and halving Δt to expect ≈2^p.
