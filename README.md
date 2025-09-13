# infoprompt

A modern, informative, and colorful Bash prompt for developers. Shows git status, Python venv, time, user, host, working directory, and more—all with emoji and color.

## Features
- Git branch, status, and merge conflict detection
- Python virtual environment name
- Last command exit code (if nonzero)
- Time, user, host, working directory
- Colorful and emoji-rich, designed for dark terminals

## Installation

1. Clone or copy this directory:
   ```sh
   git clone <repo-url> ~/projects/bashprompt
   cd ~/projects/bashprompt
   ```
2. Run the installer:
   ```sh
   bash install-bash-prompt.sh
   ```
3. Open a new terminal or run:
   ```sh
   source ~/.bash_prompt
   ```

## Uninstall
```sh
bash uninstall-bash-prompt.sh
```

## Can this be installed via apt?
No, this is not an apt package. `apt` is for system-wide packages managed by your Linux distribution. To distribute via `apt`, you would need to package it as a `.deb` file, host it in a repository, and follow Debian/Ubuntu packaging guidelines. For most users, the provided install script is the simplest and safest way.

## License
MIT (or specify your license)
