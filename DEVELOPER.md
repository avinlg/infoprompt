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

## Contact / Contributing

Open issues or PRs at https://github.com/avinlg/infoprompt.

License: `LICENSE`
