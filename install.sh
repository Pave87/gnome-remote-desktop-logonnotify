#!/usr/bin/env bash
# Install gnome-remote-desktop with the logon notification patch from
# @URL@ and keep it preferred over the Ubuntu package.
# Usage: curl -fsSL @URL@/install.sh | sudo bash
set -euo pipefail

url=@URL@
host=$(echo "$url" | sed -E 's|^https?://([^/]+).*|\1|')

install -d -m 0755 /etc/apt/keyrings
curl -fsSL "$url/key.asc" | gpg --dearmor --yes -o /etc/apt/keyrings/gnome-remote-desktop-logonnotify.gpg

cat > /etc/apt/sources.list.d/gnome-remote-desktop-logonnotify.sources <<SRC
Types: deb
URIs: $url/
Suites: ./
Signed-By: /etc/apt/keyrings/gnome-remote-desktop-logonnotify.gpg
SRC

# Always take gnome-remote-desktop from this repository, even while it lags
# behind a newer Ubuntu version (it is rebuilt daily on Ubuntu updates).
cat > /etc/apt/preferences.d/gnome-remote-desktop-logonnotify <<PIN
Package: gnome-remote-desktop
Pin: origin "$host"
Pin-Priority: 1001
PIN

apt-mark unhold gnome-remote-desktop > /dev/null 2>&1 || true
apt-get update
apt-get install -y gnome-remote-desktop
dpkg-query -W gnome-remote-desktop
