#!/usr/bin/env bash
# research-workflow: optional per-prompt collaboration contract (UserPromptSubmit).
# Opt-in: inert unless RWF_STANCE_ROUTER=1, so it never duplicates a user's own global router.
# Adds a short reminder of the stances, the approval rule for scientific assumptions, and
# derivation-backed experiments. The full guidance lives in model-development and
# researcher-in-the-loop; this only keeps it in view on every research prompt.
# Fail-open: any problem exits 0 with no output.
set -uo pipefail
[ "${RWF_STANCE_ROUTER:-}" = "1" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0
ctx='<research-collaboration>
For a research question, pick a stance (research-workflow model-development):
Explore an open question; Develop a model the researcher states (adopt it, derive
consequences on its terms, flag missing closures and inconsistencies with candidate
completions); Critique only when asked; Test (claim, falsifier, smallest decisive
test, decision rule) once the model is specified and a claim is at stake.
Scientific assumptions (closures, coefficients, approximations, regimes, boundary or
initial conditions, default parameters, pass/fail tolerances, values recalled from
memory) are proposed with their physical motivation and wait for the researcher'"'"'s
approval; mechanical choices are made and stated. Experiments are derivation-backed:
state the motivation and the predicted outcome, run once approved, report against the
prediction (research-workflow researcher-in-the-loop).
</research-collaboration>'
jq -nc --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
exit 0
