# mystation [![build-mystation](https://github.com/aussielunix/mystation/actions/workflows/build.yml/badge.svg)](https://github.com/aussielunix/mystation/actions/workflows/build.yml)

This is my continually improved cloud native (Atomic) Desktop OS.  
It is built using the fantastic [Blue Build](https://blue-build.org/) [template](https://github.com/blue-build/template) repo.

## Firstboot Runsheet

* SET TIME & DATE
* SET HOSTNAME
* `ujust -l`
* `ujust bootstrap`
* `yadm decrypt`
* `yadm remote set-url origin git@github.com:aussielunix/dotfiles.git`
* `just update_aussielunix_ca`
* `just mytoolbx`
* `just owncloud_toolbx`
* `nmcli con import type wiregurard file $HOME/.config/wireguard/mgmt.conf`
* `rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aussielunix/mystation:latest`
* `just customize_gnome`
* `systemctl enable --now --user podman-auto-update.timer`
* `systemctl reboot`
* log into ownCloud
* enter into mytoolbox and run `brew bundle install`

**Work out firefox not trusting my cacert**
- https://bgstack15.wordpress.com/2018/10/04/firefox-trust-system-trusted-certificates/

## Installation

> **Warning**
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/aussielunix/mystation:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aussielunix/mystation:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major Fedora version.

## ISO

If built on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/aussielunix/mystation
```
