# Developer guide — infoprompt

This document collects development and packaging instructions.

Files and scripts:
- Local installer: `install-bash-prompt.sh`
- Uninstaller: `uninstall-bash-prompt.sh`
- Prompt source: `bash-prompt.sh`
- Packager: `packaging/pack.sh`
- License: `LICENSE`

## Local development / testing

1. Clone or open the repo:
   ```sh
   git clone <repo-url> ~/projects/bashprompt
   cd ~/projects/bashprompt
   ```

2. Install to your home directory (developer/local installer):
   ```sh
   bash install-bash-prompt.sh
   # The installer copies bash-prompt.sh to ~/.bash_prompt and ensures ~/.bashrc sources it.
   ```

3. Test:
   ```sh
   source ~/.bash_prompt
   # Open a new terminal or source to see the prompt
   ```

4. Uninstall / cleanup:
   ```sh
   bash uninstall-bash-prompt.sh
   # This backs up ~/.bashrc and removes ~/.bash_prompt
   ```

## Building the .deb

The packager script builds a simple .deb under the `packaging` directory.

```sh
# from repository root
bash packaging/pack.sh
# Output: packaging/infoprompt_<version>_all.deb
```

`packaging/pack.sh` uses the latest git tag for the Version field (fallback `0.1.0`) and places `bash-prompt.sh` into `/usr/share/infoprompt` inside the package.

## CI / publishing

The repository includes a workflow that publishes an APT repo to GitHub Pages. Key points:
- The CI job builds the `.deb` and publishes it under the `gh-pages` branch.
- To publish signed repositories, set `GPG_PRIVATE_KEY` in CI secrets (workflow will publish `infoprompt.gpg`).

When publishing, users will add the repo with a signed key, e.g.:

```sh
sudo curl -fsSL https://avinlg.github.io/infoprompt/infoprompt.gpg | gpg --dearmor -o /usr/share/keyrings/infoprompt-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/infoprompt-archive-keyring.gpg] https://avinlg.github.io/infoprompt stable main" | sudo tee /etc/apt/sources.list.d/infoprompt.list
sudo apt update
sudo apt install infoprompt
```

## Notes

- The local installer copies `bash-prompt.sh` to `~/.bash_prompt` by default. Packaged installs put the file in `/usr/share/infoprompt/bash-prompt.sh`.
- The uninstaller backs up `~/.bashrc` to `~/.bashrc.infoprompt.bak.<timestamp>` before removing sourcing lines.
- Keep packaging changes small and test in a local VM/container before updating CI.

### /etc/profile.d strategy

The packaged `.deb` now installs a small wrapper at `/etc/profile.d/infoprompt.sh` which sources `/usr/share/infoprompt/bash-prompt.sh` for interactive/login shells. This is the recommended strategy because:

- It avoids editing users' personal dotfiles (`~/.bashrc`).
- Installing the package (`apt install infoprompt`) makes the prompt available to all users automatically for new shells.
- Removing the package (`apt remove infoprompt`) removes the wrapper so the prompt stops being automatically sourced.

If you need to migrate existing users who already used the local installer (and therefore have a `source ~/.bash_prompt` line in their `~/.bashrc`), you can either leave those lines (they are harmless) or provide optional guidance in `DEVELOPER.md` for a migration script. Note: I will not add maintainer scripts (`postinst`/`prerm`) unless you explicitly ask.

### Installer / Uninstaller behavior

- `install-bash-prompt.sh` (developer/local) **does** modify the invoking user's `~/.bashrc` by appending a small sourcing block. This is only intended for per-user development installs.
- `uninstall-bash-prompt.sh` removes that sourcing block and backs up `~/.bashrc` before doing so.

If you prefer to avoid any per-user modifications entirely, tell me and I can remove the `~/.bashrc` editing from the installer; the packaged `/etc/profile.d` wrapper is the recommended replacement.

## Contact / Contributing

Open issues or PRs at https://github.com/avinlg/infoprompt.

License: `LICENSE`
