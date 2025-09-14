#!/usr/bin/env bash
set -euo pipefail

srcdir="$(cd "$(dirname "$0")/.." && pwd)"
# Derive version from environment override, latest git tag, or fallback to 0.1.0
# Allow overriding via environment; otherwise read project VERSION file if present
if [ -z "${APT_PACKAGE_VERSION:-}" ] && [ -f "$srcdir/VERSION" ]; then
	APT_PACKAGE_VERSION="$(tr -d '[:space:]' < "$srcdir/VERSION")"
fi
version=${APT_PACKAGE_VERSION:-$(git -C "$srcdir" describe --tags --abbrev=0 2>/dev/null || echo "0.1.1")}
pkgdir="$PWD/infoprompt_${version}_pkg"

rm -rf "$pkgdir"
mkdir -p "$pkgdir/DEBIAN" "$pkgdir/usr/share/infoprompt" "$pkgdir/usr/share/doc/infoprompt" "$pkgdir/etc/profile.d"

cp "$srcdir/bash-prompt.sh" "$pkgdir/usr/share/infoprompt/bash-prompt.sh"

# Add the infoprompt CLI to manage per-user enable/disable/status
mkdir -p "$pkgdir/usr/bin"
cat > "$pkgdir/usr/bin/infoprompt" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

usage() {
	cat <<USAGE
Usage: infoprompt [options] <command>
Commands:
	status        Show whether the prompt is enabled for a user
	enable        Enable infoprompt for a user (append to ~/.bashrc)
	disable       Disable infoprompt for a user (remove from ~/.bashrc)

Options:
	-u USER       Target user (default: current user)
	-y            Assume yes (non-interactive)
	-h            Show this help
USAGE
}

target_user=""
assume_yes=0
while getopts "u:hy" opt; do
	case "$opt" in
		u) target_user="$OPTARG" ;;
		h) usage; exit 0 ;;
		y) assume_yes=1 ;;
		*) usage; exit 2 ;;
	esac
done
shift $((OPTIND-1))

cmd=${1:-}
if [ -z "$cmd" ]; then
	usage
	exit 2
fi

# Resolve default user: prefer SUDO_USER when run under sudo, else current user
if [ -z "$target_user" ]; then
	target_user=${SUDO_USER:-$(whoami)}
fi

user_home=$(getent passwd "$target_user" | cut -d: -f6 || echo "")
if [ -z "$user_home" ]; then
	echo "User '$target_user' not found or has no home directory" >&2
	exit 2
fi

bashrc="$user_home/.bashrc"
snippet_start="# Load infoprompt"
snippet="if [ -f /usr/share/infoprompt/bash-prompt.sh ]; then source /usr/share/infoprompt/bash-prompt.sh; fi"

enable() {
	if [ ! -f "$bashrc" ]; then
		sudo -u "$target_user" touch "$bashrc"
	fi
	# Add idempotent block
	if ! sudo grep -qxF "$snippet" "$bashrc" 2>/dev/null; then
		# append as the target user to keep ownership sane
		sudo -u "$target_user" sh -c "printf '\n$snippet_start\n$snippet\n' >> \"$bashrc\"" || true
		echo "infoprompt enabled for $target_user"
		logger -t infoprompt "enabled for $target_user"
	else
		echo "infoprompt already enabled for $target_user"
	fi
}

disable() {
	if [ -f "$bashrc" ]; then
		sudo sed -i '/^# Load infoprompt$/,+1d' "$bashrc" || true
		sudo sed -i '/if \[ -f \/usr\/share\/infoprompt\/bash-prompt.sh \]; then source \/usr\/share\/infoprompt\/bash-prompt.sh; fi/d' "$bashrc" || true
		echo "infoprompt disabled for $target_user"
	else
		echo "No ~/.bashrc for $target_user" >&2
		logger -t infoprompt "disable: no .bashrc for $target_user"
	fi
}

status() {
	if [ -f "$bashrc" ] && sudo grep -qxF "$snippet" "$bashrc" 2>/dev/null; then
		echo "enabled for $target_user"
		return 0
	else
		echo "disabled for $target_user"
		logger -t infoprompt "status: disabled for $target_user"
		return 1
	fi
}

case "$cmd" in
	enable) enable ;;
	disable) disable ;;
	status) status ;;
	*) usage; exit 2 ;;
esac
EOF
chmod 755 "$pkgdir/usr/bin/infoprompt"

# add a profile.d wrapper so system installs are auto-sourced for login shells
cat > "$pkgdir/etc/profile.d/infoprompt.sh" <<'EOF'
#!/bin/sh
# Source the installed prompt for interactive shells
if [ -n "$PS1" ] && [ -f /usr/share/infoprompt/bash-prompt.sh ]; then
	. /usr/share/infoprompt/bash-prompt.sh
fi
EOF
chmod 755 "$pkgdir/etc/profile.d/infoprompt.sh"


# Add control file with Depends
cat > "$pkgdir/DEBIAN/control" <<EOF
Package: infoprompt
Version: $version
Section: utils
Priority: optional
Architecture: all
Maintainer: avi <avinashgowda.1994@gmail.com>
Depends: bash
Description: infoprompt — informative bash prompt
 A colorful, git-aware Bash prompt.
EOF

# Add README.Debian
cat > "$pkgdir/usr/share/doc/infoprompt/README.Debian" <<EOF
infoprompt for Debian
---------------------

This package installs a modern, informative Bash prompt system-wide.
The prompt is automatically enabled for all users via /etc/profile.d/infoprompt.sh.

To disable, remove the package: sudo apt remove infoprompt

For local/developer installs, see the project DEVELOPER.md.
EOF

# Add minimal changelog.Debian.gz
cat > "$pkgdir/usr/share/doc/infoprompt/changelog.Debian" <<EOF
infoprompt ($version) stable; urgency=low

	* Initial release.

 -- avi <avinashgowda.1994@gmail.com>  $(date -R)
EOF
gzip -9nf "$pkgdir/usr/share/doc/infoprompt/changelog.Debian"
rm -f "$pkgdir/usr/share/doc/infoprompt/changelog.Debian"

# Add package maintainer scripts: postinst prompts to enable for current user (unless noninteractive)
cat > "$pkgdir/DEBIAN/postinst" <<'EOF'
#!/bin/sh
set -e
# Prefer SUDO_USER if available
user=${SUDO_USER:-$(logname 2>/dev/null || echo root)}
# If DEBIAN_FRONTEND=noninteractive, skip prompting and do nothing
if [ "${DEBIAN_FRONTEND:-}" = "noninteractive" ]; then
	exit 0
fi
echo
printf "Enable infoprompt for user '%s'? [Y/n] (auto-yes in 10s) " "$user"
ans=""
# Trap SIGINT (Ctrl-C) and treat it as affirmative (assume yes)
trap 'echo; echo "Interrupted, assuming yes."; ans=Y; kill "$TIMER_PID" 2>/dev/null || true' INT
# Portable timeout for /bin/sh: start a background sleep that kills the read after 10s
# Use a subshell to run the sleep so we can record its PID
( sleep 10 && kill -s ALRM $$ ) &
TIMER_PID=$!
# Use a small wrapper to perform a blocking read; POSIX read doesn't support -t on dash
# We rely on the ALRM signal to interrupt the read after the sleep expires
set +e
trap 'echo; echo "Interrupted, assuming yes."; ans=Y; kill "$TIMER_PID" 2>/dev/null || true' ALRM
read ans 2>/dev/null
rc=$?
set -e
# Clear traps and ensure timer is killed
trap - INT ALRM
kill "$TIMER_PID" 2>/dev/null || true
if [ $rc -ne 0 ] && [ -z "$ans" ]; then
	echo
	echo "No answer within 10s, assuming yes."
	ans=Y
fi
case "${ans:-Y}" in
	[Yy]*) /usr/bin/infoprompt -u "$user" -y enable || true ;;
	*) echo "Skipping per-user enable." ;;
esac
EOF
chmod 755 "$pkgdir/DEBIAN/postinst"

# postrm: remove snippet from every user's bashrc when package is removed
cat > "$pkgdir/DEBIAN/postrm" <<'EOF'
#!/bin/sh
set -e
case "$1" in
	remove|purge)
		for d in /home/* /root; do
			[ -d "$d" ] || continue
			rc="$d/.bashrc"
			if [ -f "$rc" ]; then
				sed -i '/^# Load infoprompt$/,+1d' "$rc" || true
				sed -i '/if \[ -f \/usr\/share\/infoprompt\/bash-prompt.sh \]; then source \/usr\/share\/infoprompt\/bash-prompt.sh; fi/d' "$rc" || true
				logger -t infoprompt "postrm: removed snippet from $rc"
			fi
		done
	;;
	*) ;;
esac
EOF
chmod 755 "$pkgdir/DEBIAN/postrm"


out="$(dirname "$0")/infoprompt_${version}_all.deb"
dpkg-deb --build "$pkgdir" "$out"
echo "Built $out"
