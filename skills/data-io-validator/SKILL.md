---
name: data-io-validator
description: Review data save/load code — format, units metadata, precision, portability. Use when reviewing data loading/saving code, before archiving simulation outputs, or when setting up data pipelines. Reviews portability, metadata preservation, format choices, and long-term reproducibility. Don't use for data-file or constant provenance (→ provenance), or scientific correctness of the data values (→ scientific-code-reviewer).
---

# Data I/O validator

Review data I/O code for whether an output file can be read correctly, by someone else, years from
now. Report key issues by default; give the full review with format recommendations on request.
You can't verify file contents without reading the file, and you aren't assessing I/O performance.

## Format choice

| Data Type | Recommended | Acceptable | Avoid |
|-----------|-------------|------------|-------|
| Large arrays | HDF5, Zarr | NumPy .npy/.npz | pickle |
| Tabular data | HDF5, Parquet, FITS | CSV (with schema) | Excel |
| Images/spectra | FITS | HDF5 | PNG/JPEG for data (8/16-bit integer, no float values or WCS; JPEG is also lossy) |
| Config/params | YAML, TOML | JSON | pickle |
| Checkpoints | HDF5, Zarr | .npz | pickle |

Pickle is version-fragile (tied to the Python and class definitions that wrote it) and unsafe to
load from untrusted sources. Recommendations are defaults; a project's established format can win.

## Checks

- **Units and metadata travel with the data.** Unit system and units (e.g. `"cluster"`,
  `"M_sun, pc, Myr"`), physical parameters (N, softening), code version (git hash), timestamp, and a
  run id linking to the run record. Seeds live once, in the run record (`run-reproducibility`); the
  file links to it rather than copying them. A bare `np.save("output.npy", positions)` answers none
  of "what units, what parameters".
- **Precision.** float64 is preserved where needed and not silently truncated to float32 on write
  (`.astype(np.float32)` before save); integers have an appropriate dtype; intentional precision loss
  is documented. Set the dtype explicitly on write.
- **Schema.** A complex layout has a schema file or documentation giving each dataset's shape, dtype,
  and units, with self-explanatory field names and documented nesting:
  ```yaml
  simulation_output.h5:
    /positions:      # (n_particles, 3) float64, units: pc
    /velocities:     # (n_particles, 3) float64, units: pc/Myr
    /masses:         # (n_particles,) float64, units: M_sun
    /attributes:
      unit_system:   # str, e.g., "cluster"
      time:          # float64, current simulation time in Myr
      git_hash:      # str, code version
  ```
- **Readable in 2+ years.** A widely supported format (HDF5, FITS, not custom binary), no
  Python-version-specific features (pickle protocol), minimal and stable read dependencies.
- **Large data.** Chunking matched to access (e.g. `chunks=(100, n_particles, 6)` chunks a trajectory
  by time), so one timestep reads without loading everything (`f["trajectory"][100]`); compression
  where appropriate (e.g. gzip level 4).

## Output (quick mode)

```
## Data I/O Review: [filename]
**Format:**      Using pickle for checkpoints -> recommend HDF5
**Metadata:**    No unit system recorded; missing git hash; timestamp not timezone-aware
**Precision:**   float64 preserved for positions/velocities
**Portability:** Pickle files won't survive Python version changes
```

## Related

- `provenance` — source/version/checksum discipline for external datasets.
- `run-reproducibility` — environment and run metadata needed to read outputs later.
