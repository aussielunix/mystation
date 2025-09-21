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
  dnf5 install -y \
  cloud-utils-cloud-localds \
  flatpak-spawn \
  git \
  gnome-extensions-app \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-just-perfection \
  gnome-tweaks \
  gum \
  iotop \
  jetbrains-mono-fonts-all \
  just \
  langpacks-en \
  mc \
  nmap \
  powertop \
  strace \
  terminator \
  vim-enhanced \
  webkit2gtk4.0 \
  wireguard-tools \
  wl-clipboard \
  yubikey-manager-qt
}

# DNF Remove some packages
# to be replaced with flatpaks)
dnf_remove(){
  dnf5 remove -y \
    firefox \
    passim
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
	systemctl mask ModemManager.service
	systemctl mask cups.service
	systemctl mask mcelog.service
	systemctl enable bootc-fetch-apply-updates.timer
	#Uncomment to allow disk to be extended - good for VMs etc
  #mkdir -p /usr/lib/systemd/system/local-fs.target.wants
	#ln -s /usr/lib/systemd/system/bootc-generic-growpart.service /usr/lib/systemd/system/local-fs.target.wants/bootc-generic-growpart.service
	#systemctl enable bootc-generic-growpart.service
}

main() {
  create_missing_dirs
  setup_flathub
  dnf_install
  dnf_remove
  setup_homebrew
  configure_bootc_things
  finalise
}

main "$@"
