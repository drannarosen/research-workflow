---
name: no-secrets-in-git
description: Use when staging or committing — gate that no secret or credential enters git history: an API key, token, private-key block, or a `.env`/`.pem`/credentials file is effectively permanent once committed (rewriting history is disruptive and the secret is already leaked). Keep secrets out of the repo entirely — load from the environment, commit a template, and .gitignore the real file. Backed by the `no_secrets_in_git` hook. Don't use for citing the provenance of a numeric constant (→ provenance) or for the general what-to-commit message discipline (→ decision-log-and-commits).
---

A secret committed to git stays in history after a later commit deletes it, and on any pushed, shared,
or forked repo it is compromised the moment it lands. The cleanup (rotate the credential, rewrite
history, force-push, coordinate every clone) costs far more than prevention. Credentials load from the
environment or an untracked file; the repo carries a template and a `.gitignore` entry. How secrets are
delivered (env vars, a secrets manager, an untracked dotfile, CI variables) follows the project.

## Keeping secrets out
- **Credential files stay out of the index** → `.env`, `*.pem`/`*.key`, `id_rsa`, `*.p12`/`*.pfx`, `.netrc`, `credentials`, `secrets.*` belong in `.gitignore`. A real `.env` is not tracked "to share with the team"; `.env.example` is.
- **Watch the broad add** → `git add .` / `git add -A` sweeps in whatever is untracked, including a freshly downloaded key not yet gitignored. Stage deliberately, or keep `.gitignore` ahead of the secret.
- **No inline secrets in source or config** → an `api_key = "AKIA…"` in a `.py` is the same leak as a key file, private repo or not. Read it from `os.environ`; commit a `config.example` with placeholder values.
- **Notebooks count** → output cells and saved auth tokens in `.ipynb` are a common silent leak (→ clean-notebooks territory); strip them before committing.
- **Artifacts count** → a model checkpoint or data dump can embed an access token in its metadata.
- **If it already landed** → treat it as compromised: rotate or revoke the credential first, then scrub history (`git filter-repo` / BFG) and force-push. Removal alone is not remediation.

## Related
- `decision-log-and-commits` — what *should* go in a commit, cleanly; this is the inverse guard.
- `provenance` — large data/checkpoints are also "don't commit the artifact" — reference it instead.
- `run-reproducibility` — the env that supplies secrets at runtime is part of repro setup.
