#!/usr/bin/env bash
set -euo pipefail

# Backup ~/.bashrc first
bashrc="$HOME/.bashrc"
backup="$HOME/.bashrc.infoprompt.bak.$(date +%s)"
cp "$bashrc" "$backup"

# Remove lines that source ~/.bash_prompt in common forms
# Handles: source ~/.bash_prompt, source $HOME/.bash_prompt, . ~/.bash_prompt
awk '!/^[[:space:]]*(source|\.)[[:space:]]+(~\/|\$HOME\/)?\.bash_prompt/ { print }' "$backup" > "$bashrc".tmp && mv "$bashrc".tmp "$bashrc"

# Remove the prompt file
rm -f "$HOME/.bash_prompt"

echo "infoprompt uninstalled. ~/.bashrc backed up to $backup. Restart your terminal to see the default prompt."
