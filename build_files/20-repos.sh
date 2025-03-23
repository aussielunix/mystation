#!/usr/bin/env sh

set -ouex pipefail

# example of blanketly ignoring some packages with dnf
#
#dnf config-manager --save \
#    --setopt=exclude=PackageKit,PackageKit-command-not-found,rootfiles,firefox

# EPEL
#dnf config-manager --set-enabled crb
#dnf -y install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm"

# Ublue staging COPR
#dnf5 -y copr enable ublue-os/staging

# Setup Flathub
#
mkdir -p /etc/flatpak/remotes.d
curl -o /etc/flatpak/remotes.d/flathub.flatpakrepo  https://dl.flathub.org/repo/flathub.flatpakrepo
