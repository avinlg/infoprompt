# infoprompt

 A small, informative Bash prompt package.

## Installation (recommended: via APT)

Add the repository signing key and repository, then install with `apt`:

```bash
sudo curl -fsSL https://avinlg.github.io/infoprompt/infoprompt.gpg | gpg --dearmor -o /usr/share/keyrings/infoprompt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt stable main" | sudo tee /etc/apt/sources.list.d/infoprompt.list
sudo apt-get update
sudo apt-get install infoprompt
```

## Manual / Local installation (optional, for development)

If you are developing or testing locally you can install from the built `.deb`. This is intended for development — prefer the APT route for regular use.

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

A modern, informative, and colorful Bash prompt for developers. Shows git status, Python venv, time, user, host, working directory, and more—all with emoji and color.

## Features
- Git branch, status, and merge conflict detection
- Python virtual environment name
- Last command exit code (if nonzero)
- Time, user, host, working directory
- Colorful and emoji-rich, designed for dark terminals

## Developer / Local Install (optional)

If you want to test the prompt from the repository (developer workflow):

1. Clone the repository locally:
   ```sh
   git clone <repo-url> ~/projects/bashprompt
   cd ~/projects/bashprompt
   ```
2. Run the local installer (this installs to your home directory):
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

## Contributing
- Open issues or pull requests on GitHub: https://github.com/avinlg/infoprompt
- Please keep changes small and test in a local terminal.

## License
MIT (or specify your license)
