# Setup Guide for Collaborators

This guide will help you get set up to contribute to the shifting-regime-stoich project.

## 1. Install Visual Studio Code (VSCode)

VSCode is a free code editor that works great for both R and Python.

**Download VSCode:**
- Go to https://code.visualstudio.com/
- Click "Download" and select your operating system (Windows, Mac, or Linux)
- Install the application

## 2. Install Git

Git is required to clone and collaborate on this repository.

**Download Git:**
- **Windows:** https://git-scm.com/download/win
- **Mac:** Git is usually pre-installed. Open Terminal and type `git --version` to check. If not installed, follow the prompts.
- **Linux:** Use your package manager (e.g., `sudo apt-get install git`)

## 3. Clone the Repository

Once Git is installed:

1. Open VSCode
2. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (Mac)
3. Type "Git: Clone" and press Enter
4. Paste this URL: `https://github.com/global-river-chem/shifting-regime-stoich.git`
5. Choose a folder on your computer to save the project
6. Click "Open" when prompted

## 4. Install Python (if using Python)

**Download Python:**
- Go to https://www.python.org/downloads/
- Download Python 3.11 or newer
- During installation, **check the box** that says "Add Python to PATH"

**Set up Python environment:**
1. Open Terminal in VSCode (Terminal → New Terminal)
2. Navigate to the project folder
3. Create a virtual environment:
   ```bash
   python -m venv .venv
   ```
4. Activate the environment:
   - **Mac/Linux:** `source .venv/bin/activate`
   - **Windows:** `.venv\Scripts\activate`
5. Install required packages:
   ```bash
   pip install -r requirements.txt
   ```

**Recommended VSCode Extensions for Python:**
- **Python** (by Microsoft) - Essential for Python development
- **Pylance** (by Microsoft) - Fast Python language support
- **Jupyter** (by Microsoft) - For Jupyter notebooks

Install extensions: Click the Extensions icon in VSCode sidebar or press `Ctrl+Shift+X` / `Cmd+Shift+X`

## 5. Install R (if using R)

**Download R:**
- Go to https://cran.r-project.org/
- Select your operating system and follow download instructions
- Install R

**Download RStudio (optional but recommended):**
- Go to https://posit.co/download/rstudio-desktop/
- Download and install RStudio Desktop (free version)

**Or use R in VSCode:**

Install the **R Extension** for VSCode:
- Open VSCode Extensions
- Search for "R" (by REditorSupport)
- Install it

**Install required R packages:**
```r
# In R console
install.packages("renv")
```

**Recommended VSCode Extensions for R:**
- **R** (by REditorSupport) - R language support
- **R Debugger** (by REditorSupport) - Debugging R code

## 6. Configure Git

Set up your identity for commits:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 7. Basic Git Workflow

**Pull latest changes:**
```bash
git pull
```

**Make changes to files, then commit:**
```bash
git add .
git commit -m "Description of your changes"
git push
```

## 8. Getting Help

- **VSCode Documentation:** https://code.visualstudio.com/docs
- **Git Basics:** https://git-scm.com/book/en/v2/Getting-Started-Git-Basics
- **Python Documentation:** https://docs.python.org/3/
- **R Documentation:** https://www.r-project.org/other-docs.html

## 9. Project Structure

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

## Questions?

Reach out to the team if you have any issues getting set up!
