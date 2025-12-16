#!/usr/bin/env bash

set -xeuo pipefail

# https://github.com/ublue-os/image-template/issues/71
create_missing_dirs() {
  mkdir -m 0700 -p /var/roothome
  mkdir -m 0700 -p /var/home
}

# Setup Flathub
setup_flathub() {
  mkdir -p /etc/flatpak/remotes.d
  curl -o /etc/flatpak/remotes.d/flathub.flatpakrepo  https://dl.flathub.org/repo/flathub.flatpakrepo
}

# DNF Install packages from upstream
dnf_install(){
  dnf5 clean all && \
  dnf5 update && \
  dnf5 install -y \
  adw-gtk3-theme \
  adwaita-fonts-all \
  atheros-firmware \
  bash-color-prompt \
  brcmfmac-firmware \
  brightnessctl \
  cloud-utils-cloud-localds \
  cryfs \
  davfs2 \
  ddcutil \
  evtest \
  fastfetch \
  firewall-config \
  flatpak \
  flatpak-spawn \
  flatseal \
  foo2zjs \
  fuse-encfs \
  gcc \
  git \
  git-credential-libsecret \
  glow \
  gnome-extensions-app \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-just-perfection \
  gnome-tweaks \
  gum \
  hplip \
  ibus-mozc \
  ifuse \
  igt-gpu-tools \
  input-remapper \
  iotop \
  iwd \
  iwlegacy-firmware \
  iwlwifi-dvm-firmware \
  iwlwifi-mvm-firmware \
  jetbrains-mono-fonts-all \
  just \
  kernel-modules-extra \
  krb5-workstation \
  langpacks-en \
  libgda \
  libgda-sqlite \
  libratbag-ratbagd \
  libsss_autofs \
  libxcrypt-compat \
  lm_sensors \
  lshw \
  make \
  mc \
  mesa-libGLU \
  mozc \
  mt7xxx-firmware \
  nautilus-gsconnect \
  nmap \
  nxpwireless-firmware \
  oddjob-mkhomedir \
  openssh-askpass \
  plymouth \
  plymouth-system-theme \
  powertop \
  pulseaudio-utils \
  python3-pip \
  python3-pygit2 \
  rclone \
  realtek-firmware \
  restic \
  setools-console \
  strace \
  terminator \
  tiwilink-firmware \
  usbip \
  vim-enhanced \
  waypipe \
  wireguard-tools \
  wl-clipboard \
  wpa_supplicant \
  yubikey-manager-qt \
  zenity \
  zsh
}

# DNF Remove some packages
# to be replaced with flatpaks)
dnf_remove(){
  dnf5 remove -y \
    passim \
    fedora-bookmarks \
    fedora-chromium-config \
    fedora-chromium-config-gnome \
    firefox \
    firefox-langpacks \
    gnome-software \
    gnome-software-rpm-ostree \
    gnome-terminal-nautilus
}

# Homebrew Install
setup_homebrew(){
  touch /.dockerenv
  curl --retry 3 -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  chmod +x /tmp/brew-install
  /tmp/brew-install

  tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew
  rm -f /.dockerenv

  # Clean up brew artifacts on the image.
  rm -rf /home/linuxbrew /root/.cache
  rm -r /var/home
}

# Tune bootc related things
configure_bootc_things(){
  #sed -i '/^\[composefs\]/,/^\[/ s/enabled = no/enabled = yes/' /usr/lib/ostree/prepare-root.conf

  sed -i 's,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service
}

# Finalise before baking
finalise(){
	systemctl disable ModemManager.service
	systemctl disable cups.service
	systemctl disable mcelog.service
	systemctl mask cups.service
	systemctl mask mcelog.service
	systemctl enable bootc-fetch-apply-updates.timer
	#Uncomment to allow disk to be extended - good for VMs etc
  #mkdir -p /usr/lib/systemd/system/local-fs.target.wants
	#ln -s /usr/lib/systemd/system/bootc-generic-growpart.service /usr/lib/systemd/system/local-fs.target.wants/bootc-generic-growpart.service
	systemctl enable bootc-generic-growpart.service
}

# workarounds
workarounds() {
  #ostree hates non-ascii filenames
  find / -xdev -print0 | perl -MFile::Path=remove_tree -n0e 'chomp; remove_tree($_, {verbose=>1}) if /[[:^ascii:][:cntrl:]]/'
}

main() {
  create_missing_dirs
  setup_flathub
  dnf_install
  dnf_remove
  setup_homebrew
  configure_bootc_things
  finalise
  workarounds
}

main "$@"
