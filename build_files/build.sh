#!/usr/bin/env bash

set -xeuo pipefail

# https://github.com/ublue-os/image-template/issues/71
create_missing_dirs() {
  mkdir -m 0700 -p /var/roothome
  mkdir -m 0700 -p /var/home
  mkdir -m 0700 -p /var/opt
  mkdir -m 0700 -p /var/srv
  mkdir -m 0700 -p /var/mnt
}

# Setup Flathub
setup_flathub() {
  mkdir -p /etc/flatpak/remotes.d
  curl --silent -o /etc/flatpak/remotes.d/flathub.flatpakrepo  https://dl.flathub.org/repo/flathub.flatpakrepo
}

# Setup custom COPRs and other REPOs
setup_coprs() {
  #dnf5 install --assumeyes libdnf5-plugin-appstream
  dnf5 install --assumeyes dnf5-plugins
  #dnf5 --assumeyes copr enable @osbuild/image-builder
  #dnf5 --assumeyes copr enable tnk4on/bootc-man
  dnf5 makecache --refresh
}

# DNF Install packages from upstream
dnf_install(){
  grep -vE '^#' ctx/packages.install | xargs dnf5 --setopt=install_weak_deps=False --assumeyes install --allowerasing
}

# DNF Remove some packages
# to be replaced with flatpaks)
dnf_remove(){
  grep -vE '^#' ctx/packages.remove | xargs dnf5 --assumeyes remove
  dnf5 --assumeyes autoremove
  dnf5 clean all
}

# Disable custom COPRs and other REPOs
disable_coprs() {
  #dnf5 --assumeyes copr disable @osbuild/image-builder
  #dnf5 --assumeyes copr disable tnk4on/bootc-man
  dnf5 makecache --refresh
}

# Tune bootc related things
configure_bootc_things(){
  #sed -i '/^\[composefs\]/,/^\[/ s/enabled = no/enabled = yes/' /usr/lib/ostree/prepare-root.conf

  sed -i 's,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service
}

# Finalise before baking
finalise(){
  systemctl disable cups.service
  systemctl mask cups.service
  systemctl enable bootc-fetch-apply-updates.timer
  systemctl enable rasdaemon
  #Uncomment to allow disk to be extended - good for VMs etc
  #mkdir -p /usr/lib/systemd/system/local-fs.target.wants
  #ln -s /usr/lib/systemd/system/bootc-generic-growpart.service /usr/lib/systemd/system/local-fs.target.wants/bootc-generic-growpart.service
  #systemctl enable bootc-generic-growpart.service
}

# workarounds
workarounds() {
  # pcp - Performance Co-Pilot doesn't make use of tmpfiles.d yet
  rm -rf /var/lib/pcp
  # iscsi software does not make use of tmpfiles.d yet
  rm -rf /var/lib/iscsi
  # livbirt software does not make use of tmpfiles.d yet
  rm -rf /var/lib/libvirt
  # swtpm software does not make use of tmpfiles.d yet
  rm -rf /var/lib/swtpm-localca
  rm -rf /var/lib/dnf
  rm -rf /var/lib/rpm-state
  # firebird is bad
  rm -rf /var/lib/firebird
  # cups
  rm -rf /var/lib/color
  rm -rf /var/spool/cups
  # vim
  rm -f /var/roothome/.viminfo
  # systemd things
  rm -f /var/lib/systemd/random-seed
  rm -f /var/lib/systemd/catalog/database
  # podman
  rm -rf /var/lib/containers
  # tpm2
  rm -rf /var/lib/tpm2-tss
}

main() {
  #create_missing_dirs
  setup_flathub
  #setup_coprs
  dnf_install
  dnf_remove
  #disable_coprs
  finalise
  workarounds
}

main "$@"
