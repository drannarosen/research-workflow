---
name: data-io-validator
description: Use when reviewing data loading/saving code, before archiving simulation outputs, or when setting up data pipelines. Reviews portability, metadata preservation, format choices, and long-term reproducibility.
---

# Data I/O Validator

Review data I/O code for portability, metadata preservation, format choices, and long-term reproducibility. Default to key issues only; give the full report with format recommendations on request.

## Review Process

### Format choice

**Recommended formats by use case:**

| Data Type | Recommended | Acceptable | Avoid |
|-----------|-------------|------------|-------|
| Large arrays | HDF5, Zarr | NumPy .npy/.npz | pickle |
| Tabular data | HDF5, Parquet, FITS | CSV (with schema) | Excel |
| Images/spectra | FITS | HDF5 | PNG (lossy) |
| Config/params | YAML, TOML | JSON | pickle |
| Checkpoints | HDF5, Zarr | .npz | pickle |

**Why avoid pickle:**
```python
# AVOID: Version-fragile, security risk
import pickle
with open("state.pkl", "wb") as f:
    pickle.dump(simulation_state, f)

# PREFER: Self-describing, portable
import h5py
with h5py.File("state.h5", "w") as f:
    f.create_dataset("positions", data=state.positions)
    f.create_dataset("velocities", data=state.velocities)
    f.attrs["unit_system"] = "cluster"
    f.attrs["time"] = state.time
```

### Metadata preservation

**Required metadata for scientific data:**
- [ ] Unit system documented
- [ ] Physical parameters recorded
- [ ] Code version (git hash)
- [ ] Timestamp
- [ ] Random seeds used

```python
# GOOD: Self-describing output
with h5py.File("simulation_output.h5", "w") as f:
    # Data
    f.create_dataset("positions", data=pos, dtype="float64")
    f.create_dataset("velocities", data=vel, dtype="float64")

    # Metadata
    f.attrs["unit_system"] = "cluster"
    f.attrs["units"] = "M_sun, pc, Myr"
    f.attrs["n_particles"] = n
    f.attrs["softening"] = epsilon
    f.attrs["git_hash"] = get_git_hash()
    f.attrs["created"] = datetime.now().isoformat()
    f.attrs["seed"] = seed

# BAD: Just the arrays, no context
np.save("output.npy", positions)  # What units? What parameters?
```

### Precision preservation

- [ ] Is float64 preserved where needed? (Not silently truncated to float32)
- [ ] Are integers stored with appropriate dtype?
- [ ] Is precision loss documented if intentional?

```python
# WARNING: Silent precision loss
data_float64 = np.random.randn(1000).astype(np.float64)
np.save("data.npy", data_float64.astype(np.float32))  # Lost precision!

# GOOD: Explicit about dtype
f.create_dataset("positions", data=pos, dtype="float64")
```

### Schema documentation

For complex data structures:
- [ ] Is there a schema file or documentation?
- [ ] Are field names self-explanatory?
- [ ] Are nested structures documented?

```yaml
# schema.yaml -- document your HDF5 layout
simulation_output.h5:
  /positions:      # (n_particles, 3) float64, units: pc
  /velocities:     # (n_particles, 3) float64, units: pc/Myr
  /masses:         # (n_particles,) float64, units: M_sun
  /attributes:
    unit_system:   # str, e.g., "cluster"
    time:          # float64, current simulation time in Myr
    git_hash:      # str, code version
```

### Version stability

Will this file be readable in 2+ years?

- [ ] Format is widely supported (HDF5, FITS, not custom binary)
- [ ] No Python-version-specific features (pickle protocol)
- [ ] Dependencies for reading are minimal and stable

### Large-data handling

For large datasets:
- [ ] Is chunking used appropriately?
- [ ] Can data be read partially (not all-or-nothing)?
- [ ] Is compression applied where appropriate?

```python
# GOOD: Chunked, compressed
f.create_dataset(
    "trajectory",
    data=traj,
    chunks=(100, n_particles, 6),  # Chunk by time
    compression="gzip",
    compression_opts=4
)

# Can read single timestep without loading all:
timestep_100 = f["trajectory"][100]
```

## Output Format (Quick Mode)

```
## Data I/O Review: [filename]

**Format:**
- Using pickle for checkpoints -> recommend HDF5
- FITS used for spectral data

**Metadata:**
- No unit system recorded in output
- Missing git hash / code version
- Timestamp present but not timezone-aware

**Precision:**
- float64 preserved for positions/velocities

**Portability:**
- Pickle files won't survive Python version changes
```

## Limitations

- Cannot verify actual file contents without reading
- Format recommendations may not fit all use cases
- Cannot assess I/O performance
