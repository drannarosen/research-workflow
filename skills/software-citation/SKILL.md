---
name: software-citation
description: Use when research code should be citable — set up CITATION.cff, mint a versioned Zenodo (or Software Heritage) DOI, record ORCID and CRediT contributor roles, and make a tagged release archivable so others and papers can cite the exact software version that ran. Don't use for the release process and versioning checklist itself (→ research-release-checklist), citing the numeric constants inside the code (→ provenance-of-constants), or data-archival and management planning (→ data-management-plan).
---

Research software that papers depend on should be citable like any other scholarly product — by DOI, to a specific version, with credited contributors. A bare GitHub URL is not a citation; it moves, forks, and disappears.

## Discipline
- **Ship a CITATION.cff** → machine-readable, at the repo root; GitHub renders a "Cite this repository" box from it.
- **Mint a versioned DOI** → archive releases (Zenodo archives a GitHub *release*, not a bare tag; Software Heritage archives the repo) and have the *paper* cite the version-specific DOI, so the citation pins the code that produced the result.
- **Know the DOI timing trap** → Zenodo mints a version DOI only *after* the GitHub release is published, so a release can never contain its own version DOI. Put the **concept DOI** (resolves to the latest version) in CITATION.cff and the README; record the version DOI in the paper and in the *next* release's changelog.
- **Credit honestly** → ORCIDs for authors and CRediT-style roles (software, methodology, data curation) so contribution is legible.
- **Sync the version everywhere** → the git tag, CITATION.cff `version`, and package metadata name the same version; the version DOI follows the release (see the timing trap).
- **Tell users how to cite** → a "How to cite" section in the README or docs pointing at the current DOI.

## Anti-patterns
- "Cite our GitHub repo" with no DOI and no version.
- A CITATION.cff whose version has drifted from the actual release tag.
- Citing the concept DOI, so a reader can't tell which version produced the result.
- Omitting contributors who wrote substantial parts of the code.

## Hard vs adaptable
- **Hard rule:** code behind a published result is citable to a specific version by DOI, with a CITATION.cff that matches the tag.
- **Adaptable:** archive (Zenodo vs Software Heritage vs institutional) and how rich the contributor metadata is scale to the project.

## Related
- `research-release-checklist` — the release that the DOI archives.
- `provenance-of-constants` — citing the science inside the code, not the code itself.
- `decision-log-and-commits` — the commit history behind a tagged release.
- `data-management-plan` — the data counterpart to software citation.
