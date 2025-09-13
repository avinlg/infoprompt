#!/usr/bin/env bash
set -e
rm -f "$HOME/.bash_prompt"
sed -i '/source ~/.bash_prompt/d' "$HOME/.bashrc"
echo "infoprompt uninstalled. Restart your terminal to see the default prompt."
