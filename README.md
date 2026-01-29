# Shifting Regime Stoichiometry

Analysis for shifting regime stoichiometry paper.

## Project Overview

This repository contains data analysis workflows for investigating shifting regime stoichiometry in river systems.

**Meeting Notes:** [Shared Google Doc](https://docs.google.com/document/d/1zCGwtSoNqc0L-JvHTbFOjYTho3IRfmo_j76OIo6s4Ks/edit?tab=t.0) 

**Track project progress:** [Shifting-Regimes Paper Project Board](https://github.com/orgs/global-river-chem/projects/2)

## Repository Structure

```
shifting-regime-stoich/
├── src/
│   ├── python/         # Python analysis scripts
│   └── r/              # R analysis scripts
├── notebooks/          # Jupyter and R Markdown notebooks
├── docs/               # Documentation
├── requirements.txt    # Python package dependencies
└── README.md          # Project overview
```

## Getting Started

**New collaborators:** See [docs/setup.md](docs/setup.md) for detailed setup instructions including VSCode, Python, R, and Git configuration.

### Quick Setup - Python Environment

```bash
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### Quick Setup - R Environment

```r
# Install renv if not already installed
install.packages("renv")

# Restore R package environment
renv::restore()
```

## Contributing

1. Pull the latest changes: `git pull`
2. Make your changes in the appropriate directory (`src/python/`, `src/r/`, or `notebooks/`)
3. Commit and push: `git add .` → `git commit -m "Description"` → `git push`

See the [setup guide](docs/setup.md) for more details.
