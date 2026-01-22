# Shifting Regime Stoichiometry

Analysis for shifting regime stoichiometry paper.

## Project Overview

This repository contains data analysis workflows for investigating shifting regime stoichiometry in river systems.

## Data

Raw data files should be placed in `data/raw/`. Processed data outputs go in `data/processed/`.

## Analysis

Analysis scripts are organized in:
- `src/python/` - Python analysis scripts
- `src/r/` - R analysis scripts
- `notebooks/` - Jupyter and R Markdown notebooks

## Results

Figures and outputs are saved to:
- `figures/` - Publication-quality figures
- `results/` - Analysis results and tables

## Setup

### Python Environment

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### R Environment

```r
# Install renv if not already installed
install.packages("renv")

# Restore R package environment
renv::restore()
```

## Project Status

Track project progress and tasks on the [GitHub Projects board](https://github.com/orgs/global-river-chem/projects).
