#!/usr/bin/env bash
set -e
cp "$(dirname "$0")/bash-prompt.sh" "$HOME/.bash_prompt"
if ! grep -q 'source ~/.bash_prompt' "$HOME/.bashrc"; then
  echo 'source ~/.bash_prompt' >> "$HOME/.bashrc"
  echo "Added 'source ~/.bash_prompt' to ~/.bashrc"
else
  echo "~/.bashrc already sources ~/.bash_prompt"
fi
echo "infoprompt installed! Open a new terminal or run: source ~/.bash_prompt"
