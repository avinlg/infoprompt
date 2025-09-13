#!/usr/bin/env bash
# infoprompt (installable)

# Function to show Python virtual environment name if active
venv_info() {
  [ -n "$VIRTUAL_ENV" ] && echo -n "🐍($(basename "$VIRTUAL_ENV")) "
}

# Function to get detailed Git information
git_info() {
  # Return if git is not available or not a repo
  command -v git >/dev/null 2>&1 || return
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local branch commit status ahead behind ut staged modified s conflict
  s=""
  conflict=""
  branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git rev-parse --short HEAD 2>/dev/null)
  commit=$(git rev-parse --short HEAD 2>/dev/null)
  status=$(git status --porcelain=2 --branch 2>/dev/null)
  ahead=$(echo "$status" | grep '^#' | grep -o 'ahead [0-9]*' | grep -o '[0-9]*')
  behind=$(echo "$status" | grep '^#' | grep -o 'behind [0-9]*' | grep -o '[0-9]*')
  ut=$(echo "$status" | grep '^?' | wc -l | tr -d ' ')
  # staged (cached) changes count
  staged=$(git diff --name-only --cached 2>/dev/null | wc -l | tr -d ' ')
  # modified but unstaged files
  modified=$(git ls-files -m 2>/dev/null | wc -l | tr -d ' ')
  s=""
  [ "$ahead" != "" ] && s+="↑$ahead "
  [ "$behind" != "" ] && s+="↓$behind "
  [ "$ut" != "0" ] && s+="ut:$ut "
  [ "$staged" != "0" ] && s+="st:$staged "
  [ "$modified" != "0" ] && s+="m:$modified "
  # Detect merge conflicts reliably
  if git ls-files -u 2>/dev/null | grep -q .; then
    conflict="⚔️ MERGE CONFLICT "
  fi
  git diff --quiet --ignore-submodules HEAD 2>/dev/null
  if [ $? -eq 0 ]; then
    s+="🟢"
  else
    s+="🔴"
  fi
  if [ -z "$commit" ]; then
    echo -n " 🌱 ${branch} ${s} ${conflict}No commits yet "
  else
    echo -n " 🌱 ${branch} ${s} ${conflict}c:${commit} "
  fi
}

# Function to show last command exit status if nonzero
exit_code_info() {
  local status=$?
  if [ "$status" -ne 0 ]; then
    echo -n "❌ $status Last command failed"
  fi
}

# Compose PS1 with improved formatting for black background
export PS1='\[\033[1;31m\]$(exit_code_info)\[\033[0m\]\n'
PS1+='\[\033[1;36m\]⏰ \t \[\033[0m\]'
PS1+='\[\033[1;32m\]$(git_info)\[\033[0m\] '
PS1+='\[\033[1;35m\]$(venv_info)\[\033[0m\] '
PS1+='\[\033[1;34m\]🖥️  \u@\h \[\033[0m\]'
PS1+='\[\033[1;33m\] 📁 \w \[\033[0m\]'
PS1+='\n\[\033[1;35m\]:$\[\033[0m\] '
export PS1
