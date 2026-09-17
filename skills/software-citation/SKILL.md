---
name: software-citation
description: Use when research code should be citable — set up CITATION.cff, archive a version with a persistent identifier (DOI or Software Heritage ID), record ORCID and CRediT contributor roles, and make a tagged release archivable so others and papers can cite the exact software version that ran. Don't use for the release process and versioning checklist itself (→ research-release-checklist), citing the numeric constants inside the code (→ provenance-of-constants), or a funder data management plan (grant-writing grant-budget-and-docs).
---

Research software that papers depend on should be citable like any other scholarly product — by DOI, to a specific version, with credited contributors. A bare GitHub URL is not a citation; it moves, forks, and disappears.

## Discipline
- **Ship a CITATION.cff** → machine-readable, at the repo root; GitHub renders a "Cite this repository" box from it.
- **Cite a specific version** → archive the release in a repository that issues a persistent identifier, and have the *paper* cite the identifier for the exact version that produced the result — not the repository's front page.
- **Credit honestly** → ORCIDs for authors and CRediT-style roles (software, methodology, data curation) so contribution is legible.
- **Sync the version everywhere** → the git tag, CITATION.cff `version`, and package metadata name the same version.
- **Tell users how to cite** → a "How to cite" section in the README or docs pointing at the current DOI.

## Anti-patterns
- "Cite our GitHub repo" with no DOI and no version.
- A CITATION.cff whose version has drifted from the actual release tag.
- Citing an identifier that resolves to "latest", so a reader can't tell which version produced the result.
- Omitting contributors who wrote substantial parts of the code.

## Hard vs adaptable
- **Hard rule:** code behind a published result is citable to a specific version by DOI, with a CITATION.cff that matches the tag.
- **Adaptable:** archive (Software Heritage, institutional repository, or another DOI-issuing archive) and how rich the contributor metadata is scale to the project.

## Related
- `research-release-checklist` — the release that the DOI archives.
- `provenance-of-constants` — citing the science inside the code, not the code itself.
- `decision-log-and-commits` — the commit history behind a tagged release.
- `data-provenance` — the data counterpart: source, version, and checksum of datasets (funder data management plans live in the grant-writing plugin's `grant-budget-and-docs`).
