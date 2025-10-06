# Begin with a standard bootc base image that is reused as a "builder" for the custom image.
FROM quay.io/fedora/fedora-bootc:42 as builder
# Configure and override source RPM repositories, if necessary. This step is not required when building up from minimal unless referencing specific content views or target mirrored/snapshotted/pinned versions of content.
# Add additional repositories to apply customizations to the image. However, referencing a custom manifest in this step is not currently supported without forking the code.
# Build the root file system by using the specified repositories and non-RPM content from the "builder" base image.
# If no repositories are defined, the default build will be used. You can modify the scope of packages in the base image by changing the manifest between the "standard" and "minimal" sets.
RUN /usr/libexec/bootc-base-imagectl build-rootfs --manifest=standard /target-rootfs

# Create a new, empty image from scratch.
FROM scratch
# Copy the root file system built in the previous step into this image.
COPY --from=builder /target-rootfs/ /
# Apply customizations to the image. This syntax uses "heredocs" https://www.docker.com/blog/introduction-to-heredocs-in-dockerfiles/ to pass multi-line arguments in a more readable format.
RUN <<EORUN
# Set pipefail to display failures within the heredoc and avoid false-positive successful builds.
set -xeuo pipefail
mkdir -p /etc/flatpak/remotes.d
curl -o /etc/flatpak/remotes.d/flathub.flatpakrepo  https://dl.flathub.org/repo/flathub.flatpakrepo
# Install required packages for our custom bootc image.
# Note that using a minimal manifest means we need to add critical components specific to our use case and environment.
dnf5 -y --setopt=install_weak_deps=False install gcc
dnf5 --assumeyes group install gnome-desktop
dnf5 --assumeyes install \
  cloud-utils-cloud-localds \
  flatpak-spawn \
  flatseal \
  gnome-extensions-app \
  gnome-shell-extension-appindicator \
  gnome-shell-extension-just-perfection \
  gnome-tweaks \
  iotop \
  jetbrains-mono-fonts-all \
  just \
  kernel-modules-extra \
  langpacks-en \
  libvirt \
  mc \
  nmap \
  podman-compose \
  podmansh \
  qemu-user-binfmt \
  qemu \
  strace \
  terminator \
  vim-enhanced \
  virt-install \
  virt-manager \
  virt-viewer \
  wireguard-tools \
  wl-clipboard \
  yubikey-manager-qt

#dnf5 --assumeyes remove mod_http2 httpd httpd-core httpd-filesystem
# Remove package caches
dnf5 clean all

# Clean up all logs and caches
rm /var/{log,cache,lib}/* -rf
# Run the bootc linter to perform build-time verification. Keep this as the last command in your build instructions.
bootc container lint
# Close the shell command.
EORUN

# Define required labels for this bootc image to be recognized as such.
LABEL containers.bootc 1
LABEL ostree.bootable 1
LABEL org.opencontainers.image.title="Aussielunix Workstation"
LABEL org.opencontainers.image.authors="Mick Pollard <mick@aussielunix.io>"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"

# Optional labels that only apply when running this image as a container. These keep the default entry point running under systemd.
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
