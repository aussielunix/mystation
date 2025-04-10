#!/usr/bin/env sh

set -ouex pipefail

# Add and instantly disable Ublue packages COPR
#dnf5 -y copr enable ublue-os/packages
#dnf5 -y copr disable ublue-os/packages

# Setup Flathub
#
mkdir -p /etc/flatpak/remotes.d
curl -o /etc/flatpak/remotes.d/flathub.flatpakrepo  https://dl.flathub.org/repo/flathub.flatpakrepo
