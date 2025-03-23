#!/usr/bin/env bash

set -ouex pipefail

# Install things from upstream
#
dnf5 install -y \
  cloud-utils-cloud-localds \
  flatpak-spawn \
  git \
  gnome-extensions-app \
  gnome-shell-extension-appindicator \
  gnome-tweaks \
  iotop \
  jetbrains-mono-fonts-all \
  just \
  langpacks-en \
  libvirt \
  mc \
  nmap \
  qemu-char-spice \
  qemu-device-display-virtio-gpu \
  qemu-device-display-virtio-vga \
  qemu-device-usb-redirect \
  qemu-img \
  qemu-system-x86-core \
  qemu-user-binfmt \
  qemu-user-static \
  qemu \
  strace \
  terminator \
  vim-enhanced \
  virt-install \
  virt-manager \
  virt-viewer \
  webkit2gtk4.0 \
  wireguard-tools \
  wl-clipboard \
  yubikey-manager-qt \
  zstd

## Install things from Ublue's Staging COPR
#
#dnf5 --enable-repo=copr:copr.fedorainfracloud.org:ublue-os:staging \
#  install -y devpod

## Install things from MS VSCode repo
#
#dnf --enable-repo=vscode-yum \
#  install -y code

## Install gcc as a workaound for homebrew
#
dnf5 -y --setopt=install_weak_deps=False install gcc

## Remove some packages (to be replaced with flatpaks)
#
#dnf5 remove -y firefox passim

dnf5 clean all
rm -rf /var/{cache,log} /var/lib/{dnf,rhsm}
