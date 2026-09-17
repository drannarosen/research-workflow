---
name: research-release-checklist
description: Use when cutting a release of research code, pairing software to a paper, or making code citable — semantic versioning, changelog, CITATION.cff with ORCID and CRediT roles, archiving the exact version under a persistent identifier the paper cites, the "every published figure regenerates from the release" check, and confirming the external-validation milestone is done. Don't use for recording individual runs or the environment (→ run-reproducibility), the validation stages themselves (→ verification-gate), or a funder data management plan (grant-writing grant-budget-and-docs).
---

A release is when code becomes the citable, reproducible artifact behind a result. The bar: someone with only the release can regenerate the paper's figures, and can cite the exact version that made them.

## Checklist
- **Version and changelog** → semantic versioning; the version behind the paper is tagged and frozen; the changelog says in human terms what changed.
- **External validation done** → the milestone that was owed during development (published results or reference-code comparisons, → verification-gate *Validation stages*, `reference-parity-audit`) is complete for every claim the paper makes.
- **Figure → artifact trace** → each published figure maps to a script or notebook plus inputs that regenerate it from the release (→ run-reproducibility).
- **Environment frozen** → the release carries its lock so it still runs in a year.
- **Clean state at the tag** → no secrets, no stubs, tests green.

## Citability
- **CITATION.cff** at the repo root (GitHub renders "Cite this repository"), with `version` matching the tag and package metadata.
- **Credit** → ORCIDs and CRediT roles (software, methodology, data curation) for everyone who wrote substantial parts.
- **Cite the version, not the project** → archive the release in a repository that issues a persistent identifier, and have the paper cite the identifier of the exact version that produced the results — not a front page or an identifier that resolves to "latest".
- **Tell users how to cite** in the README or docs.

## Anti-patterns
- "Cite our GitHub repo" with no version or identifier.
- A published figure no released script can regenerate.
- A CITATION.cff whose version has drifted from the tag.
- Releasing a commit whose environment is unspecified.

## Related
- `run-reproducibility` — the run records and environment the release freezes.
- `verification-gate` — the validation stages; external validation is due by release.
- `reference-parity-audit` — the parity comparisons a release may need to cite.
- `no-secrets-in-git` / `no-stub-when-done` — the clean-state gates before tagging.
