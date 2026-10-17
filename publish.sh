#!/usr/bin/env bash
# Turn the .deb files in $1 into a signed flat apt repository in $2.
# The signing key must already be in the gpg keyring; its fingerprint is $3.
# $4 is the URL the repository is served from (used in install.sh).
set -euo pipefail

debs=$1
site=$2
key=$3
url=$4
here=$(cd "$(dirname "$0")" && pwd)

mkdir -p "$site"
cp "$debs"/*.deb "$site/"
cd "$site"

apt-ftparchive packages . > Packages
gzip -9kf Packages
apt-ftparchive \
  -o APT::FTPArchive::Release::Origin=gnome-remote-desktop-logonnotify \
  -o APT::FTPArchive::Release::Label=gnome-remote-desktop-logonnotify \
  -o APT::FTPArchive::Release::Suite=resolute \
  -o APT::FTPArchive::Release::Codename=resolute \
  release . > Release
gpg --batch --yes --local-user "$key" --clearsign -o InRelease Release
gpg --batch --yes --local-user "$key" -abs -o Release.gpg Release
gpg --armor --export "$key" > key.asc

sed "s|@URL@|$url|g" "$here/install.sh" > install.sh
