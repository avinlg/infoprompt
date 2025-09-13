#!/usr/bin/env bash
set -euo pipefail

srcdir="$(cd "$(dirname "$0")/.." && pwd)"
# Derive version from latest git tag, fallback to 0.1.0
version=$(git -C "$srcdir" describe --tags --abbrev=0 2>/dev/null || echo "0.1.0")
pkgdir="$PWD/infoprompt_${version}_pkg"

rm -rf "$pkgdir"
mkdir -p "$pkgdir/DEBIAN" "$pkgdir/usr/share/infoprompt" "$pkgdir/usr/share/doc/infoprompt" "$pkgdir/etc/profile.d"

cp "$srcdir/bash-prompt.sh" "$pkgdir/usr/share/infoprompt/bash-prompt.sh"

# add a profile.d wrapper so system installs are auto-sourced for login shells
cat > "$pkgdir/etc/profile.d/infoprompt.sh" <<'EOF'
#!/bin/sh
# Source the installed prompt for interactive shells
if [ -n "$PS1" ] && [ -f /usr/share/infoprompt/bash-prompt.sh ]; then
	. /usr/share/infoprompt/bash-prompt.sh
fi
EOF
chmod 755 "$pkgdir/etc/profile.d/infoprompt.sh"

cat > "$pkgdir/DEBIAN/control" <<EOF
Package: infoprompt
Version: $version
Section: utils
Priority: optional
Architecture: all
Maintainer: avi <avinashgowda.1994@gmail.com>
Description: infoprompt — informative bash prompt
 A colorful, git-aware Bash prompt.
EOF

out="$(dirname "$0")/infoprompt_${version}_all.deb"
dpkg-deb --build "$pkgdir" "$out"
echo "Built $out"
