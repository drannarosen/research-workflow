---
name: research-release-checklist
description: Use when cutting a release of research code or pairing software to a paper — semantic versioning for research artifacts, a changelog, the tag ↔ archived DOI ↔ paper linkage, and the "every figure traces to a released, runnable artifact" check. Don't use for the citation-metadata mechanics alone (→ software-citation), the local reproducibility/environment contract (→ reproducible-environment-contract), or data-archival planning (→ data-management-plan).
---

A release is the moment code becomes a citable, reproducible artifact behind a result. The bar is simple and strict: someone with only the release can reproduce the figures in the paper.

## Checklist
- **Version meaningfully** → semantic versioning; the version that produced the paper's results is tagged and frozen.
- **Changelog** → what changed since the last release, in human terms; reviewers and future-you read it.
- **Tag ↔ DOI ↔ paper** → the git tag is archived to a DOI (→ software-citation), the paper cites that DOI, and the release notes link the paper.
- **Figure → artifact trace** → each published figure maps to a script or notebook plus inputs reproducible from the release (→ artifact-first-reproducibility).
- **Environment frozen** → the release carries an environment lock so it still runs in a year (→ reproducible-environment-contract).
- **Clean state at the tag** → no secrets, no stubs, tests green at the tagged commit.

## Anti-patterns
- Tagging "v1.0" with no changelog and no archived DOI.
- A paper that cites "the code" with no version matching the results.
- A published figure that no released script can regenerate.
- Releasing a commit whose environment is unspecified, so it won't run later.

## Hard vs adaptable
- **Hard rule:** the released, tagged, DOI-archived version reproduces the paper's figures from its own inputs and environment.
- **Adaptable:** how much of the figure→artifact trace is automated versus documented scales to the project's size.

## Related
- `software-citation` — DOI and CITATION.cff metadata for the release.
- `artifact-first-reproducibility` — every figure traces to a runnable artifact.
- `reproducible-environment-contract` — the frozen environment shipped with the release.
- `no-secrets-in-git` — the clean-state gate (with `no-stub-when-done`) before tagging.
