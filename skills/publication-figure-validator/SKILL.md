---
name: publication-figure-validator
description: Use before submitting figures for publication (ApJ, MNRAS, Nature), proposals (NSF, NASA), or presentations. Validates matplotlib/plotting CODE against journal standards, accessibility, and typography requirements (size/DPI/fonts/format). Don't use for whether a rendered figure faithfully represents the data (→ plot-faithfulness-inspector) or for design quality and figure ideation (→ plot-design-inspector).
---

# Publication Figure Validator

Validate matplotlib/plotting code against journal, proposal, and presentation standards. Default to a concise checklist; give the full report with suggested rcParams on request.

## Validation Modes

### Mode: Journal (ApJ, MNRAS, A&A, Nature)

Strict standards for peer review.

| Journal | Single Col | Double Col | Min DPI | Preferred Format |
|---------|------------|------------|---------|------------------|
| ApJ     | 3.5 in     | 7.1 in     | 300     | PDF/EPS |
| MNRAS   | 3.3 in     | 6.97 in    | 300     | PDF/EPS |
| A&A     | 3.5 in     | 7.1 in     | 300     | PDF/EPS |
| Nature  | 89 mm      | 183 mm     | 300     | PDF/EPS/TIFF |

### Mode: Proposal (NSF, NASA)

Some panels print in grayscale. Larger fonts for readability.
- Font size: minimum 10pt at final size
- Must work in grayscale for some reviewers
- Higher contrast requirements

### Mode: Presentation (Slides, Posters)

Optimized for projection/printing.
- Larger fonts (14pt+ recommended)
- Higher contrast
- Simpler layouts

### Mode: Lab / Internal

Relaxed standards for exploratory work.
- 150 DPI acceptable
- Slightly smaller fonts OK
- Must still have labels and units

## Review Process

### Size and resolution

- [ ] Figure size matches target (journal column, slide dimensions)
- [ ] DPI >= 300 for raster elements (>=150 for lab)
- [ ] Vector format for line plots (PDF, EPS, SVG)

### Typography

- [ ] Font size readable at final size (>=6pt journal, >=10pt proposal, >=14pt slides)
- [ ] Consistent font family throughout
- [ ] Math rendered properly (LaTeX)
- [ ] No pixelated text

### Labels and units

- [ ] All axes labeled
- [ ] Units included (in label or caption)
- [ ] Standard notation (e.g., `[$M_\odot$]`, `[km s$^{-1}$]`)
- [ ] Colorbar labeled if present

### Accessibility

- [ ] Colormap is NOT jet/rainbow
- [ ] Colormap is perceptually uniform (viridis, cividis, plasma)
- [ ] Works in grayscale (required for proposals, good practice for journals)
- [ ] Lines distinguishable by style AND color
- [ ] Sufficient contrast

### Data presentation

- [ ] Error bars/bands shown where appropriate
- [ ] Data points not obscured
- [ ] Legend doesn't overlap data
- [ ] Appropriate plot type for data

### Style consistency

- [ ] Same style across all figures in paper/proposal
- [ ] Line weights consistent
- [ ] Marker sizes consistent
- [ ] Color scheme consistent

## Output Format (Quick Mode)

```
## Figure Validation: [target]

**Target:** ApJ single column (3.5 x 2.8 in @ 300 DPI)

**Issues:**
- Font size 6pt -> increase to 8pt minimum
- Using 'jet' colormap -> switch to 'viridis'
- Axis labels have units

**Status:** PASS WITH NOTES
```

## Suggested rcParams

```python
# ApJ single-column figure
plt.rcParams.update({
    'figure.figsize': (3.5, 2.8),
    'figure.dpi': 300,
    'font.size': 9,
    'font.family': 'serif',
    'axes.labelsize': 10,
    'axes.titlesize': 10,
    'xtick.labelsize': 8,
    'ytick.labelsize': 8,
    'legend.fontsize': 8,
    'lines.linewidth': 1.0,
    'lines.markersize': 4,
})
```

## Limitations

- Cannot view actual rendered output
- Style preferences vary by editor/reviewer
- Some checks require running the code
