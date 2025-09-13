# infoprompt

 A small, informative Bash prompt packaged as a .deb and served via GitHub Pages APT repository.

## Installation (recommended: via APT)

- Add the repository signing key and repository:

```bash
sudo curl -fsSL https://avinlg.github.io/infoprompt/infoprompt.gpg | gpg --dearmor -o /usr/share/keyrings/infoprompt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt stable main" | sudo tee /etc/apt/sources.list.d/infoprompt.list
sudo apt-get update
sudo apt-get install infoprompt
```

If you prefer not to use the signed key, you can add the repo without `signed-by` (less secure):

```bash
echo "deb https://avinlg.github.io/infoprompt stable main" | sudo tee /etc/apt/sources.list.d/infoprompt.list
sudo apt-get update
sudo apt-get install infoprompt
```

## Manual installation

If you want to install the package without adding the APT repository, download the latest `.deb` and install with `dpkg`:

```bash
curl -LO https://raw.githubusercontent.com/avinlg/infoprompt/gh-pages/pool/main/i/infoprompt/infoprompt_0.1.0_all.deb
sudo dpkg -i infoprompt_0.1.0_all.deb
sudo apt-get install -f   # fix dependencies if any
```

## Requirements

- A Linux system with Bash (tested on Ubuntu/Debian).
- `apt` / `dpkg` for package installation (for the APT route).
- Optional: `gpg` to import the signing key when using the signed repo.

## Where to use

This package installs a small script that configures a Bash prompt (`bash-prompt.sh`) which you can source from your `~/.bashrc` or copy into system-wide locations like `/etc/profile.d/`.

Example (per-user): add this to `~/.bashrc`:

```bash
if [ -f /usr/share/infoprompt/bash-prompt.sh ]; then
  source /usr/share/infoprompt/bash-prompt.sh
fi
```

The prompt is git-aware and shows virtual environment information, exit codes, branch/status, and emojis to help readability.

## Development & Packaging

- Package builder: `packaging/pack.sh` builds the `.deb` (places artifact in repository root and CI copies it into the APT repo during workflow).
- CI publishes an APT repository to GitHub Pages at `https://avinlg.github.io/infoprompt/` and will sign releases if `GPG_PRIVATE_KEY` is configured in repository secrets.

## Troubleshooting

- If `apt-get update` fails to fetch the repository, confirm Pages is published and `infoprompt.gpg` is reachable.
- To debug locally, download the `.deb` manually and inspect the contents with `dpkg-deb -c infoprompt_*.deb`.

---
If you'd like, I can add a `USAGE.md` with more examples or update the package `Version` on each git tag.# infoprompt

A modern, informative, and colorful Bash prompt for developers. Shows git status, Python venv, time, user, host, working directory, and more—all with emoji and color.

## Features
- Git branch, status, and merge conflict detection
- Python virtual environment name
- Last command exit code (if nonzero)
- Time, user, host, working directory
- Colorful and emoji-rich, designed for dark terminals

## Installation

1. Clone or copy this directory:
   ```sh
   git clone <repo-url> ~/projects/bashprompt
   cd ~/projects/bashprompt
   ```
2. Run the installer:
   ```sh
   bash install-bash-prompt.sh
   ```
3. Open a new terminal or run:
   ```sh
   source ~/.bash_prompt
   ```

## Uninstall
```sh
bash uninstall-bash-prompt.sh
```

## Prompt status fields
The prompt shows concise git and workspace status fields. Their meanings:

- `ut:<n>` : number of untracked files (not added to git)
- `st:<n>` : number of staged (indexed) changes ready to commit
- `m:<n>`  : number of modified (tracked) files with unstaged changes
- `🟢` / `🔴`: repository clean or dirty (uncommitted changes)
- `⚔️ MERGE CONFLICT`: shows when unmerged conflict markers exist

These are designed to be lightweight and computed with standard git commands so the prompt remains responsive.

## Troubleshooting
- If the prompt shows no git info, ensure `git` is installed and you're inside a git repository.
- If colors look wrong, make sure your terminal supports ANSI colors (most modern terminals do).

## Contributing
- Open issues or pull requests on GitHub: https://github.com/avinlg/infoprompt
- Please keep changes small and test in a local terminal.

## Can this be installed via apt?
No, this is not an apt package. `apt` is for system-wide packages managed by your Linux distribution. To distribute via `apt`, you would need to package it as a `.deb` file, host it in a repository, and follow Debian/Ubuntu packaging guidelines. For most users, the provided install script is the simplest and safest way.

### Publish to GitHub Pages
This repo includes a sample GitHub Actions workflow that builds a simple `.deb` and publishes an apt repository to the `gh-pages` branch using `reprepro` and `actions-gh-pages`.

Once the workflow runs and publishes, users can add the repo with (example):

```bash
curl -fsSL https://avinlg.github.io/infoprompt/infoprompt.gpg | sudo gpg --dearmor -o /usr/share/keyrings/infoprompt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt/ stable main" \
   | sudo tee /etc/apt/sources.list.d/infoprompt.list
sudo apt update
sudo apt install infoprompt
```

Note: the sample workflow publishes unsigned repositories by default. To secure the repo, enable GPG signing and publish the public key (infoprompt.gpg) alongside the repo.

### Enabling GPG-signed repositories (optional)
1. Create a GPG key locally:

```bash
gpg --full-generate-key
gpg --armor --export you@example.com > infoprompt.gpg
```

2. Add the private key to your repository secrets (Settings → Secrets → Actions) as `GPG_PRIVATE_KEY` (export with `gpg --export-secret-keys --armor YOUR_KEY_ID`).

3. The workflow will import the private key and sign the repository, publishing `infoprompt.gpg` (public key) for users to import.

## License
MIT (or specify your license)
