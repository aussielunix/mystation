# update tls ca certificate store
update_aussielunix_ca:
  sudo wget --no-check-certificate https://cacert.hl.valueline.io/aussielunix_Root_CA_168848365996868199089383065266162030969.crt --output-document=/etc/pki/ca-trust/source/anchors/aussielunix_Root_CA_168848365996868199089383065266162030969.crt
  sudo /usr/bin/update-ca-trust

# create my daily driver toolbox
mytoolbx:
  #!/usr/bin/env bash
  toolbox create --image ghcr.io/aussielunix/mytoolbx:latest -c mytoolbx
  mkdir -p .local/share/systemd/user
  cd .local/share/systemd/user
  podman generate systemd -n mytoolbx --files
  cd -
  systemctl --user daemon-reload
  systemctl --user enable container-mytoolbx.service --now

# Create and run owncloud toolbox under systemd
owncloud_toolbx:
  #!/usr/bin/env bash
  toolbox create --image ghcr.io/aussielunix/owncloud-toolbx:latest -c owncloud
  mkdir -p $HOME/.local/share/systemd/user
  cd $HOME/.local/share/systemd/user
  podman generate systemd -n owncloud --new --files
  cat << __EOF__ > owncloud-client.service
  [Unit]
  Description=Owncloud Client - Open Source Continuous File Synchronization
  Documentation=man:owncloud(1)
  StartLimitIntervalSec=60
  StartLimitBurst=4
  Wants=network-online.target
  After=network-online.target

  [Service]
  ExecStart=/usr/bin/toolbox run --container owncloud owncloud
  Restart=on-failure
  RestartSec=1
  SuccessExitStatus=3 4
  RestartForceExitStatus=3 4

  # Hardening
  SystemCallArchitectures=native
  MemoryDenyWriteExecute=true
  NoNewPrivileges=true

  [Install]
  WantedBy=default.target
  __EOF__
  cd -
  systemctl --user daemon-reload
  systemctl --user enable container-owncloud.service --now
  systemctl --user enable owncloud-client.service --now

# Customize Gnome settings
customize_gnome:
  echo "Tuning a bunch of Gnome settings with gsettings"
  gsettings set org.gnome.desktop.background picture-uri-dark 'file:///usr/share/backgrounds/fedora-workstation/petals_dark.webp'
  gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/fedora-workstation/petals_light.webp'
  gsettings set org.gnome.desktop.background primary-color '#000000000000'
  gsettings set org.gnome.desktop.background secondary-color '#000000000000'
  gsettings set org.gnome.desktop.interface clock-show-weekday true
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  gsettings set org.gnome.desktop.interface show-battery-percentage true
  gsettings set org.gnome.desktop.notifications application-children "['gnome-power-panel', 'org-gnome-nautilus']"
  gsettings set org.gnome.shell enabled-extensions "['appindicatorsupport@rgcjonas.gmail.com']"
  gsettings set org.gnome.shell favorite-apps ['org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'org.mozilla.firefox.desktop', 'terminator.desktop', 'org.keepassxc.KeePassXC.desktop', 'org.chromium.Chromium.desktop']
  gsettings set org.gnome.shell disabled-extensions "['background-logo@fedorahosted.org']"
  gsettings set org.gnome.shell.app-switcher current-workspace-only true
  gsettings set org.gnome.desktop.interface enable-hot-corners false
  gsettings set org.gnome.nautilus.preferences migrated-gtk-settings true
  gsettings set org.gnome.desktop.screensaver picture-uri 'file:///usr/share/backgrounds/fedora-workstation/petals_light.webp'
  gsettings set org.gnome.desktop.screensaver primary-color '#000000000000'
  gsettings set org.gnome.desktop.screensaver secondary-color '#000000000000'
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 8
  gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
  gsettings set org.gnome.desktop.search-providers disable-external true
  gsettings set org.gnome.nautilus.window-state maximized true
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.mutter edge-tiling false

