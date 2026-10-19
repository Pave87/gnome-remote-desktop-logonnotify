# gnome-remote-desktop-logonnotify

Ubuntu 26.04 `gnome-remote-desktop` with one patch: the RDP server sends the
logon notification (Save Session Info PDU, [MS-RDPBCGR] 3.3.5.10.1). Without
it, the Windows Remote Desktop Connection client (mstsc) never adds the host
to its connection history.

The patch is the same change as the upstream merge request. Remove this
repository once Ubuntu ships the fix.

## Install on a VM

```
curl -fsSL https://pave87.github.io/gnome-remote-desktop-logonnotify/install.sh | sudo bash
```

This adds the signing key, the apt source and a pin so `gnome-remote-desktop`
always comes from here. Then restart the service (this drops RDP sessions):

```
sudo systemctl restart gnome-remote-desktop.service
```

## How it stays current

A GitHub Actions workflow runs daily in an `ubuntu:26.04` container. It takes
Ubuntu's current source package, adds `patches/rdp-send-logon-notification.patch`,
builds it as `<ubuntu version>+logonnotify<PATCH_REVISION>` and publishes a
signed apt repository on GitHub Pages. If the version is already published it
does nothing. If the patch stops applying to a new Ubuntu version, the run
fails and GitHub notifies you.

After changing the patch, increase `PATCH_REVISION`.

## Remove

```
sudo rm /etc/apt/sources.list.d/gnome-remote-desktop-logonnotify.sources \
        /etc/apt/preferences.d/gnome-remote-desktop-logonnotify \
        /etc/apt/keyrings/gnome-remote-desktop-logonnotify.gpg
sudo apt-get update
sudo apt-get install --allow-downgrades gnome-remote-desktop/resolute-updates
```
