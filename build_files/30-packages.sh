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
  gnome-shell-extension-just-perfection \
  gnome-tweaks \
  iotop \
  jetbrains-mono-fonts-all \
  just \
  langpacks-en \
  mc \
  nmap \
  strace \
  terminator \
  vim-enhanced \
  webkit2gtk4.0 \
  wireguard-tools \
  wl-clipboard \
  yubikey-manager-qt \
  zstd

## Install things from Ublue's packages COPR
#
#dnf5 --enablerepo copr:copr.fedorainfracloud.org:ublue-os:packages \
#  install -y <foo>

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
