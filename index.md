---
route: default

---
# infoprompt

 A small, informative Bash prompt package.

 The prompt is git-aware and shows virtual environment information, exit codes, branch/status, and emojis to help readability.

## Features
- Git branch, status, and merge conflict detection
- Python virtual environment name
- Last command exit code (if nonzero)
- Time, user, host, working directory
- Colorful and emoji-rich, designed for dark terminals

## Requirements

- A Linux system with Bash (tested on Ubuntu/Debian).
- `apt` / `dpkg` for package installation (for the APT route).
- Optional: `gpg` to import the signing key when using the signed repo.

## Installation (recommended: via APT)

Add the repository signing key and repository, then install with `apt`:

```bash
# Import the repository public key and dearmor it to a system keyring (non-interactive, safe overwrite)
sudo sh -c 'curl -fsSL https://avinlg.github.io/infoprompt/infoprompt.gpg | gpg --dearmor -o /usr/share/keyrings/infoprompt-archive-keyring.gpg'

# Add the repository source line idempotently (won't add duplicates)
grep -qxF 'deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt stable main' /etc/apt/sources.list.d/infoprompt.list || \
  echo 'deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt stable main' | sudo tee -a /etc/apt/sources.list.d/infoprompt.list

sudo apt-get update
sudo apt-get install infoprompt
```

## Uninstall
```sh
sudo apt-get remove infoprompt
```

For developer and packaging details, see [`DEVELOPER.md`](./DEVELOPER.md) in this repository.

---

License: The project is licensed under MIT. See [`LICENSE`](LICENSE) for details.

## Command Usage

The package installs a small management CLI at `/usr/bin/infoprompt` to enable, disable, and check status for users.

Usage:

```sh
infoprompt [options] <command>

Commands:
  status        Show whether the prompt is enabled for a user
  enable        Enable infoprompt for a user (append to ~/.bashrc)
  disable       Disable infoprompt for a user (remove from ~/.bashrc)

Options:
  -u USER       Target user (default: current user or the original sudo user)
  -y            Assume yes (non-interactive)
  -h            Show help
```

Examples:

```sh
# Enable for the current user interactively
infoprompt enable

# Enable for a specific user non-interactively
infoprompt -u alice -y enable

# Check status for the installing user (when run under sudo this checks SUDO_USER)
infoprompt status

# Disable for a user
infoprompt -u alice disable
```
