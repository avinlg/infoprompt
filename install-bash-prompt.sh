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

# Ensure ~/.bashrc contains a source line for the prompt (handles variations)
bashrc="$HOME/.bashrc"
if ! grep -Eqs '^[[:space:]]*(source|\.)[[:space:]]+(~\/|\$HOME\/)?\.bash_prompt' "$bashrc"; then
  echo '' >> "$bashrc"
  echo '# Load infoprompt' >> "$bashrc"
  echo 'if [ -f "$HOME/.bash_prompt" ]; then' >> "$bashrc"
  echo '  source "$HOME/.bash_prompt"' >> "$bashrc"
  echo 'fi' >> "$bashrc"
  echo "Added sourcing block to $bashrc"
else
  echo "$bashrc already sources .bash_prompt"
fi

echo "infoprompt installed to $target. Open a new terminal or run: source ~/.bash_prompt"
