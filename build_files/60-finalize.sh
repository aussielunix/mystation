#!/usr/bin/env bash

set -euox pipefail

#mkdir -p /usr/lib/systemd/system/local-fs.target.wants
#ln -s /usr/lib/systemd/system/bootc-generic-growpart.service /usr/lib/systemd/system/local-fs.target.wants/bootc-generic-growpart.service

systemctl disable ModemManager.service
systemctl disable cups.service
systemctl disable mcelog.service

systemctl mask ModemManager.service
systemctl mask cups.service
systemctl mask mcelog.service

#systemctl enable gdm.service
systemctl enable bootc-fetch-apply-updates.timer
#systemctl enable bootc-generic-growpart.service
#systemctl set-default graphical.target

#dnf5 -y copr disable ublue-os/staging
