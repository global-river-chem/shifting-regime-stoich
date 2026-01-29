# Setup Guide for Collaborators

This guide will help you get set up to contribute to the shifting-regime-stoich project.

## 1. Install Visual Studio Code (VSCode) or Positron

VSCode and Positron are free code editors that work well for both R and Python.  
Both editors include **built-in Git support**, allowing you to work with Git directly from the editor.

### Download VSCode
- Go to https://code.visualstudio.com/
- Click **Download** and select your operating system
- Install the application

### Download Positron
- Go to https://positron.posit.co/
- Click **Download** and choose your operating system
- Install the application

## 2. Install Git (Required)

Git is required to collaborate on this repository.  
VSCode and Positron include **built-in Git interfaces**, but Git itself must be installed on your system for these features to work.

You do **not** need to use Git from the command line unless you want to—VSCode and Positron handle Git operations (clone, commit, pull, push) directly from the editor.

### Download Git
- **Windows:** https://git-scm.com/download/win
- **macOS:** Git is usually pre-installed. Open Terminal and run `git --version` to check. If not installed, follow the prompts.

## 3. Clone the Repository Using VSCode or Positron

You can clone the repository **directly inside VSCode or Positron** (no command line required).

1. Open VSCode or Positron
2. Open the **Source Control** panel (branch icon on the left sidebar)
3. Click **Clone Repository**
4. Paste the repository URL
5. Choose a local folder where the project should live
6. When prompted, click **Open** to open the cloned repository

> You may be asked to sign in to GitHub (or another Git provider) the first time.

## 4. Basic Git Workflow Inside VSCode or Positron

### Making Changes
- Edit files as needed
- Changed files will automatically appear in the **Source Control** panel

### Committing Changes
1. Open the **Source Control** panel
2. Review the list of changed files
3. Enter a short, descriptive commit message (e.g., `Update analysis script`)
4. Click **Commit**

### Pulling Updates
Before starting work, it’s a good idea to pull the latest changes:
- Click **Pull** from the Source Control menu, or
- Use the sync button in the status bar

### Pushing Changes
After committing:
- Click **Push** (or **Sync Changes**) to upload your commits to the remote repository

## 5. Recommended Workflow

1. Pull latest changes
2. Make edits
3. Commit your changes with a clear message
4. Push your changes
   
