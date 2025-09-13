#!/usr/bin/env bash
#!/usr/bin/env bash
set -euo pipefail

srcdir="$(cd "$(dirname "$0")" && pwd)"
target="$HOME/.bash_prompt"

# If the package is installed system-wide prefer that and instruct the user
if command -v apt >/dev/null 2>&1 && dpkg -s infoprompt >/dev/null 2>&1; then
  echo "infoprompt appears to be installed via APT system-wide. To use the packaged prompt, ensure /usr/share/infoprompt/bash-prompt.sh is sourced from your shell initialization files (see README)."
fi

# Backup existing prompt file if present
if [ -f "$target" ]; then
  backup="$HOME/.bash_prompt.bak.$(date +%s)"
  cp -a "$target" "$backup"
  echo "Existing ~/.bash_prompt backed up to $backup"
fi

cp "$srcdir/bash-prompt.sh" "$target"
chmod 644 "$target"
echo
echo "infoprompt copied to $target"
echo "To enable the prompt for your current shell, run:"
echo "  source \"$HOME/.bash_prompt\""
echo
echo "To enable the prompt automatically for future shells, add the following to your ~/.bashrc (optional):"
echo
echo 'if [ -f "$HOME/.bash_prompt" ]; then'
echo '  source "$HOME/.bash_prompt"'
echo 'fi'
echo
echo "Note: system installations via APT provide /etc/profile.d/infoprompt.sh and do not require per-user edits."
