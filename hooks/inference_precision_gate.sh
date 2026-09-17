#!/usr/bin/env bash
# research-workflow HITL: two narrow Stop checks on REPORTED numbers, each a single non-obvious trap.
#  (R) A posterior estimate reported with an uncertainty (± / credible interval) but no sampler
#      diagnostics (R-hat / ESS / n_eff) anywhere in the message or this turn's tool output.
#      An unconverged posterior summary has no meaning (-> bayesian-inference-gate).
#  (P) In a JAX project, an error / drift / residual / tolerance below ~1e-7 reported with no
#      jax_enable_x64 evidence (message, turn commands/output, or the repo). JAX defaults to float32,
#      whose resolution is ~1.2e-7, so such a number is either x64 or an artifact (-> numerical-precision).
# Self-limiting: anything labeled exploratory / preliminary / quick look / not yet checked is exempt —
#   development numbers are the supervisor's call (verification-gate, "Validation stages").
# Subagent-safe: exits 0 inside a subagent (.agent_id), like the other Stop gates.
# Fail-open: any parsing problem exits 0 (allow).
set -uo pipefail
__d=$(cd "$(dirname "$0")" 2>/dev/null && pwd || true)
[ -n "${__d:-}" ] && [ -r "$__d/_log.sh" ] && . "$__d/_log.sh"
type rwf_log >/dev/null 2>&1 || rwf_log() { :; }
type rwf_stop >/dev/null 2>&1 || rwf_stop() { jq -nc --arg r "$1" '{decision:"block",reason:$r}'; }
[ -n "${__d:-}" ] && [ -r "$__d/_turn.sh" ] && . "$__d/_turn.sh"
type rwf_current_turn >/dev/null 2>&1 || rwf_current_turn() { [ -r "$1" ] && tail -n 250 "$1"; }
command -v jq >/dev/null 2>&1 || { rwf_log inference-precision "allow:no-jq"; exit 0; }
input=$(cat)

event=$(jq -r '.hook_event_name // empty' <<<"$input" 2>/dev/null) || exit 0
agent_id=$(jq -r '.agent_id // empty' <<<"$input" 2>/dev/null) || exit 0
if [ "$event" = "SubagentStop" ]; then
  [ -n "${RWF_SUBAGENT_EVIDENCE:-}" ] || { rwf_log inference-precision "allow:subagent-gate-off"; exit 0; }
else
  [ -n "$agent_id" ] && { rwf_log inference-precision "allow:subagent" "$agent_id"; exit 0; }
fi

last=$(jq -r '.last_assistant_message // empty' <<<"$input" 2>/dev/null | tr '\n' ' ')
[ -n "$last" ] || { rwf_log inference-precision "allow:empty-last"; exit 0; }
tp=$(jq -r '.transcript_path // empty' <<<"$input" 2>/dev/null)
cwd=$(jq -r '.cwd // empty' <<<"$input" 2>/dev/null); [ -n "$cwd" ] || cwd="."

# Development-stage labels exempt both checks.
if grep -Eiq 'exploratory|preliminary|quick[- ]look|sanity[- ]check|not (yet )?(converg|check|validat)|unconverged|rough (estimate|number)' <<<"$last"; then
  rwf_log inference-precision "allow:exploratory-label"; exit 0
fi

# This turn's tool commands and results (same window as the evidence gate).
turn=""
if [ -n "$tp" ] && [ -r "$tp" ]; then
  turn=$(rwf_current_turn "$tp" | jq -rc '
      if .type=="assistant" then (.message.content // [] | if type=="array" then (.[] | select(.type=="tool_use") | (.input.command // "" | tostring)) else empty end)
      elif .type=="user" then (.message.content // [] | if type=="array" then (.[] | select(.type=="tool_result") | (.content | if type=="array" then ([.[]?.text] | join(" ")) else tostring end)) else empty end)
      else empty end' 2>/dev/null)
fi

block() { # tag  reason
  rwf_log inference-precision "block:$1" "$last"
  rwf_stop "research-workflow inference/precision gate: $2"
  exit 0
}

# (R) posterior estimate without diagnostics.
posterior_ctx='posterior|credible (interval|region)|MCMC|NUTS|HMC|nested sampling|marginali[sz]ed'
estimate_re='[0-9]\.?[0-9]*[[:space:]]*(±|\+/-|\\pm)|\^\{\+[0-9]|(68|95|90)[[:space:]]*%|16(th)?[/–-]84(th)?'
diag_re='r[_-]?hat|R̂|split[_ ]r|\bESS\b|ess_(bulk|tail)|n_eff|effective sample size|print_summary|az\.summary|arviz'
if grep -Eiq "$posterior_ctx" <<<"$last" && grep -Eq "$estimate_re" <<<"$last"; then
  if ! grep -Eiq "$diag_re" <<<"$last" && ! grep -Eiq "$diag_re" <<<"$turn"; then
    block "posterior-without-diagnostics" "the final message reports a posterior estimate with an uncertainty, but neither it nor this turn's output shows sampler diagnostics (split R-hat, bulk/tail ESS, divergences). Show them (e.g. mcmc.print_summary() or arviz.summary), or label the number exploratory. See bayesian-inference-gate."
  fi
fi

# (P) sub-float32 precision claim in a JAX project without x64 evidence.
# A sentence counts only if it pairs a precision word with a number below 1e-7.
precision_hit=$(awk '
  BEGIN { RS="[.;!?]+[[:space:]]+" }
  {
    s=$0; low=tolower(s)
    if (low !~ /(error|drift|residual|tolerance|tol=|rtol|atol|converged|conserv|delta ?e|δe|de\/e)/) next
    gsub(/−/, "-", s)
    while (match(s, /[0-9]+(\.[0-9]+)?[[:space:]]*([eE]|[x×][[:space:]]*10\^?)[[:space:]]*-[0-9]+/)) {
      tok=substr(s, RSTART, RLENGTH); s=substr(s, RSTART+RLENGTH)
      mant=tok; sub(/[[:space:]]*([eE]|[x×]).*/, "", mant)
      ex=tok; sub(/.*-/, "", ex)
      if ((mant+0) * 10^(-(ex+0)) < 1e-7) { print tok; exit }
    }
  }' <<<"$last")
if [ -n "$precision_hit" ]; then
  is_jax=0
  if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    git -C "$cwd" grep -qE '^[[:space:]]*(import jax|from jax)' -- '*.py' 2>/dev/null && is_jax=1
  fi
  grep -Eq '(import jax|from jax|jnp\.)' <<<"$turn" && is_jax=1
  if [ "$is_jax" -eq 1 ]; then
    x64_re='jax_enable_x64|JAX_ENABLE_X64|enable_x64'
    has_x64=0
    grep -Eq "$x64_re" <<<"$last" && has_x64=1
    grep -Eq "$x64_re" <<<"$turn" && has_x64=1
    git -C "$cwd" grep -qE "$x64_re" 2>/dev/null && has_x64=1
    if [ "$has_x64" -eq 0 ]; then
      block "sub-float32-precision-without-x64" "the final message reports $precision_hit as an error/drift/residual/tolerance in a JAX project, but there is no jax_enable_x64 evidence in the message, this turn, or the repo. JAX defaults to float32 (resolution ~1.2e-7), so this number is either an x64 result — say so and show where x64 is enabled — or a float32 artifact. See numerical-precision."
    fi
  fi
fi

rwf_log inference-precision "allow:clean"
exit 0
