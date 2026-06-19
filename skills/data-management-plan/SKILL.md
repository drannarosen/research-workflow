---
name: data-management-plan
description: Use when planning how research data and outputs are stored, documented, licensed, and shared — funder-required data management plans (NSF/NASA), FAIR principles, repository and format choices, metadata and data dictionaries, embargo and license terms, and retention. Don't use for validating data I/O code (→ data-io-validator), input-dataset source/version/checksum provenance (→ data-provenance), or software citation and DOIs (→ software-citation).
---

Funders increasingly require a data management plan, and the plan is also just good practice: data nobody can find, read, or reuse dies with the project. Decide where outputs live, how they are described, and who may use them — before generating terabytes you can't archive.

## Discipline
- **FAIR by design** → Findable (DOI/identifier, indexed metadata), Accessible (open repository, clear access terms), Interoperable (open formats), Reusable (license plus provenance plus documentation).
- **Pick the repository early** → a domain or general archive (Zenodo, Dataverse, community archives such as MAST) chosen before the data exists, not scrambled for at submission.
- **Plan metadata and formats** → open, documented formats (→ data-io-validator) and a data dictionary so a stranger can read the files.
- **License explicitly** → a data license (e.g. CC-BY or CC0) and any embargo, so reuse terms are unambiguous.
- **Right-size retention** → decide what is archived versus regenerable, raw versus derived; budget cost and volume up front.

## Anti-patterns
- Writing the DMP only because the funder demands it, then ignoring it.
- "We'll share on request," with no repository and no identifier.
- Proprietary or undocumented formats no one can open later.
- No license, leaving reusers unsure what is permitted.
- Planning to archive raw volumes that are cheaper to regenerate — or discarding ones that aren't.

## Hard vs adaptable
- **Hard rule:** research outputs have a named repository, an identifier, documented formats, and an explicit license before they are relied on.
- **Adaptable:** archive choice, metadata depth, and retention policy scale to the data's volume and reuse value.

## Related
- `data-provenance` — source, version, and checksum of input datasets.
- `data-io-validator` — portable formats and preserved metadata in the I/O code.
- `software-citation` — the software counterpart to a data DOI.
- `artifact-first-reproducibility` — archived data behind reproducible results.
