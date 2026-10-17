#!/usr/bin/env bash
# Build gnome-remote-desktop from the current Ubuntu source package with the
# logon notification patch added.
#
# Needs deb-src enabled, plus: dpkg-dev devscripts quilt and the package's
# build dependencies (apt-get build-dep gnome-remote-desktop).
#
# Environment:
#   OUT                 directory for the built .deb files (default: ./out)
#   PUBLISHED_PACKAGES  URL of an already published Packages file; if it
#                       already lists the version that would be built, skip.
#   FORCE               "true" to build even if already published.
#
# Writes the built version to $OUT/VERSION, or nothing if skipped.
set -euo pipefail

here=$(cd "$(dirname "$0")" && pwd)
OUT=${OUT:-$here/out}
rev=$(cat "$here/PATCH_REVISION")
patch_name=rdp-send-logon-notification.patch

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"

apt-get source -q gnome-remote-desktop > /dev/null
src=$(find . -maxdepth 1 -type d -name 'gnome-remote-desktop-*' | head -n 1)
cd "$src"

ubuntu_version=$(dpkg-parsechangelog -S Version)
version="${ubuntu_version}+logonnotify${rev}"
echo "Ubuntu version: $ubuntu_version"
echo "Build version:  $version"

if [ "${FORCE:-false}" != true ] && [ -n "${PUBLISHED_PACKAGES:-}" ] &&
   curl -fsSL "$PUBLISHED_PACKAGES" 2> /dev/null | grep -qx "Version: $version"; then
  echo "$version is already published, nothing to do"
  exit 0
fi

cp "$here/patches/$patch_name" debian/patches/
echo "$patch_name" >> debian/patches/series
QUILT_PATCHES=debian/patches quilt push -a

DEBFULLNAME="gnome-remote-desktop-logonnotify" \
DEBEMAIL="noreply@localhost" \
  dch -v "$version" -D "$(dpkg-parsechangelog -S Distribution)" --force-distribution \
  "Send RDP logon notification (MS-RDPBCGR 3.3.5.10.1) so mstsc remembers the host."

# The upstream test suite needs a full session (mutter, PipeWire) and fails in
# containers for unrelated reasons; the patch has its own upstream test.
DEB_BUILD_OPTIONS=nocheck dpkg-buildpackage -us -uc -b

mkdir -p "$OUT"
cp ../*.deb "$OUT/"
echo "$version" > "$OUT/VERSION"
ls -l "$OUT"
