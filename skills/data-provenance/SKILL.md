---
name: data-provenance
description: Use when code ingests external input data — datasets, catalogs, observational tables, pretrained checkpoints, lookup grids — gate that every such input carries a recorded source (URL/DOI/Zenodo), a version or data-release, and a checksum before any result depends on it. Pairs with the provenance.sh data hook. Don't use for hardcoded physical constants/coefficients in source (→ provenance-of-constants), logging which dataset a given run used (→ experiment-tracking), or pinning the software environment (→ reproducible-environment-contract).
---

An input you can't identify is a result you can't defend. Every external data artifact the code reads — a survey catalog, an observational table, an opacity grid, a pretrained checkpoint — must be pinned to *where it came from*, *which version*, and *a checksum that proves you have the bytes you think you have*, before any result is allowed to depend on it. Default: an external input with no recorded provenance does not feed a reported result.

## What every external input records
Captured in committed metadata (a manifest, a pointer file, a loader assertion) — not tribal knowledge:
- **Source** → a resolvable origin: URL, DOI, Zenodo record, survey data-release page, or the generating script if you produced it. "From a colleague" or "downloaded once" is not a source.
- **Version / release** → the dataset version or data release (`Gaia DR3`, not "Gaia"), table revision, or checkpoint tag. Surveys reissue and recalibrate; "latest" is not a version.
- **Checksum** → a content hash (e.g. sha256) recorded next to the path, so a silently re-downloaded, truncated, or corrupted file is *caught*, not used.
- **Access date** → when it was fetched, for sources that lack immutable versioning.
- **License / citation terms** → if redistribution is restricted or a citation is required.

The manifest answers "what exactly is this file, where is it from, and is it intact?" for every input — keyed so `experiment-tracking` can point a run's config at it.

## Anti-patterns
- A hardcoded path to a file no manifest explains (`/scratch/me/v2_final_FINAL.h5`).
- "Latest" / unversioned dataset references that change underneath you between runs.
- Trusting a download with no checksum — corruption and silent re-releases pass undetected.
- A checkpoint loaded by filename with no record of the data/commit/run that produced it.
- Committing *derived* data with no pointer back to the raw inputs and the transform that made it.

## Hard vs adaptable
- **Hard rule:** every external input a result depends on is **identifiable** (source + version) and **verifiable** (checksum) from committed metadata. An unidentifiable input is an unciteable result — the no-fabrication rule applied to data.
- **Adaptable:** the mechanism — a `data/SOURCES.md` manifest, DVC/datalad pointers, a checksum sidecar, or a loader that asserts the hash on read. Match the data's scale and sensitivity; what must survive is **identify + verify**.

This skill governs *bytes that enter from outside*; numbers hardcoded *in the source* are `provenance-of-constants`.

## Related
- `provenance-of-constants` — the in-code sibling: cited constants/coefficients vs. external data files.
- `experiment-tracking` — a run's config points at the dataset id/version this skill pins down.
- `reproducible-environment-contract` — pins the software stack; this pins the data inputs.
- `artifact-first-reproducibility` — derived artifacts must trace back through this to their raw inputs.
