---
name: scientific-code-reviewer
description: Use when reviewing physics/astrophysics code for scientific correctness — units, physical bounds, conservation laws, dimensional consistency, AI-generated calculations. Don't use for JAX mechanics (→ jax-code-validator), numerical stability/precision (→ numerical-methods-auditor), or figure/I-O review.
---

# Scientific Code Reviewer

Review computational-astrophysics code for scientific correctness: units, physical bounds, conservation laws, dimensional consistency. Default to a concise issue list; give the full report on request.

## Review Process

### Step 1: Identify Physical Quantities

Scan the code and list all variables that represent physical quantities:
- What are they? (mass, velocity, energy, etc.)
- What units should they have?
- What are their valid ranges?

### Step 2: Unit Consistency Check

**Physical units mode:**
- Is astropy.constants / astropy.units used?
- Are unit conversions documented and correct?

**Named code units mode:**
- Is the unit system documented? (e.g., "stellar: M_sun, R_sun, Myr" or "cluster: M_sun, pc, Myr")
- Is the code internally consistent with that named system?
- JAX-native constants inside tight loops are acceptable if documented.

**Red flags:**
- Mixed unit systems without explicit conversion
- Hardcoded constants without unit annotation AND without documented code units
- `G = 6.674e-11` alongside `c = 3e10` (SI + CGS mixed!)
- SI constants appearing in code that claims to use CGS or named code units

**Not a red flag:**
- Named code unit system with documented constants (e.g., `G = 0.004498` for cluster units)
- CGS constants throughout with CGS documented

### Step 3: Physical Bounds Check

For each computed quantity:
- [ ] Can it be negative when it shouldn't be? (mass, temperature, density)
- [ ] Can it exceed physical limits? (v > c, T < 0)
- [ ] Are infinities/singularities handled? (r -> 0, division by zero)

### Step 4: Conservation Laws

Identify what should be conserved:
- [ ] Energy (for closed systems, conservative forces)
- [ ] Momentum (linear and angular)
- [ ] Mass (for non-relativistic, non-reactive systems)
- [ ] Other invariants (Jacobi integral, adiabatic invariants)

**For simulation engines (N-body, hydro):**
- Recommend explicit tests asserting conservation within tolerance over long integrations
- Check for existing tests that verify relative energy error < specified tolerance
- Don't just suggest "eyeball the conservation" -- push toward automated tests

### Step 5: Dimensional Analysis

For key equations:
- [ ] Write out dimensions of LHS and RHS
- [ ] Do they match?
- [ ] Are dimensionless quantities actually dimensionless?

### Step 6: Analytic or Reference Limits

- [ ] Does the code reproduce known analytic solutions where they exist?
- [ ] Does it match published results / figures from papers?
- [ ] What happens at limiting cases (M -> 0, r -> infinity, t -> 0)?

**Note:** Many real modules (SSE, SCF, cluster metrics) only have semi-analytic or literature comparisons. That's acceptable -- don't demand analytic solutions for inherently messy physics.

## Output Format (Quick Mode)

```
## Scientific Review: [filename]

**Unit system:** [CGS / SI / Code units (G=1, M_sun, pc) / Mixed]

**Issues found:**
- Line 42: No guard against radius <= 0
- Line 87: Mixed CGS/SI without conversion
- Conservation: Energy conservation test exists

**Recommendations:**
1. Add radius > 0 assertion
2. Standardize to CGS or add explicit conversion
```

For a deep review, expand the same dimensions into a per-quantity table (variable · meaning · expected units · valid range) with PASS / PASS-WITH-NOTES / FAIL per section.

## Limitations

- Cannot verify numerical accuracy without running code
- Cannot assess appropriateness of physical approximations without domain context
- Does not replace physicist judgment on model validity
