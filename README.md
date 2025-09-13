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

## Features
- Git branch, status, and merge conflict detection
- Python virtual environment name
- Last command exit code (if nonzero)
- Time, user, host, working directory
- Colorful and emoji-rich, designed for dark terminals

## Uninstall
Remove the local installer changes:

```sh
bash uninstall-bash-prompt.sh
```

For developer and packaging details, see [`DEVELOPER.md`](./DEVELOPER.md) in this repository.

---

License: The project is licensed under MIT. See [`LICENSE`](LICENSE) for details.
