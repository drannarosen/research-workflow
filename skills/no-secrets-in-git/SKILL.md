---
name: no-secrets-in-git
description: Use when staging or committing — gate that no secret or credential enters git history: an API key, token, private-key block, or a `.env`/`.pem`/credentials file is effectively permanent once committed (rewriting history is disruptive and the secret is already leaked). Keep secrets out of the repo entirely — load from the environment, commit a template, and .gitignore the real file. Backed by the `no_secrets_in_git` hook. Don't use for citing the provenance of a numeric constant (→ provenance-of-constants) or for the general what-to-commit message discipline (→ decision-log-and-commits).
---

A secret committed to git is a secret leaked. Deleting it in a later commit does nothing — it lives in history forever, and on any pushed/shared/forked repo it must be treated as compromised the instant it lands (rotate it, don't just remove it). The expensive part isn't the gate; it's the cleanup: history rewrite, force-push, coordinating every clone, rotating the credential. So the rule is preventive: a secret or credential file never gets staged in the first place. Default: credentials load from the environment or an untracked file; the repo carries a template and a `.gitignore` entry, never the real value.

## Keeping secrets out
- **Never `git add` a credential file** → `.env`, `*.pem`/`*.key`, `id_rsa`, `*.p12`/`*.pfx`, `.netrc`, `credentials`, `secrets.*` belong in `.gitignore`, not the index.
- **Watch the broad add** → `git add .` / `git add -A` sweeps in whatever is untracked; the secret you forgot to `.gitignore` rides along. Stage deliberately, or keep `.gitignore` ahead of the secret.
- **No inline secrets in source** → an `api_key = "AKIA…"` hardcoded in a `.py` is the same leak as a key file. Read it from `os.environ`; commit a `config.example` with placeholder values.
- **If it already landed** → assume it's compromised: rotate/revoke the credential first, then scrub history (`git filter-repo` / BFG) and force-push. Removal alone is not remediation.
- **Notebooks count** → output cells and saved auth tokens in `.ipynb` are a common silent leak (→ clean-notebooks territory); strip them before committing.

## Anti-patterns
- A real `.env` (not `.env.example`) tracked in the repo "just to share with the team."
- Hardcoded tokens/passwords in source or config, committed because "it's a private repo."
- `git add .` that pulls in a freshly downloaded key/credential before it's gitignored.
- "I'll remove it in the next commit" — the secret is already permanent in history.
- Committing a model checkpoint or data dump that embeds an access token in its metadata.

## Hard vs adaptable
- **Hard rule:** no secret or credential file enters the index. Secrets come from the environment or an untracked file; the repo holds a template + a `.gitignore` entry.
- **Adaptable:** how secrets are delivered (env vars, a secrets manager, an untracked dotfile, CI variables) — match the project. What must survive: the live value is never in git history.

## Related
- `decision-log-and-commits` — what *should* go in a commit, cleanly; this is the inverse guard.
- `data-provenance` — large data/checkpoints are also "don't commit the artifact" — reference it instead.
- `reproducible-environment-contract` — the env that supplies secrets at runtime is part of repro setup.
- `provenance-of-constants` — a cited physical constant *belongs* in the repo; a secret never does.
