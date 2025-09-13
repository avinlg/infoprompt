#!/usr/bin/env bash
set -euo pipefail

srcdir="$(cd "$(dirname "$0")/.." && pwd)"
version="${VERSION:-0.1.0}"
pkgdir="$PWD/infoprompt_${version}_pkg"

rm -rf "$pkgdir"
mkdir -p "$pkgdir/DEBIAN" "$pkgdir/usr/share/infoprompt" "$pkgdir/usr/share/doc/infoprompt"

cp "$srcdir/bash-prompt.sh" "$pkgdir/usr/share/infoprompt/bash-prompt.sh"

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

dpkg-deb --build "$pkgdir" "infoprompt_${version}_all.deb"
echo "Built infoprompt_${version}_all.deb"
