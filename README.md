# mystation [![build-mystation](https://github.com/aussielunix/mystation/actions/workflows/build.yml/badge.svg)](https://github.com/aussielunix/mystation/actions/workflows/build.yml)

This is my continually improved cloud native (Atomic) Desktop OS.  
It is built using the fantastic [Blue Build](https://blue-build.org/) [template](https://github.com/blue-build/template) repo.

## Firstboot Runsheet

* Check TIME & DATE
* Check HOSTNAME is a FQDN
* `ujust -l`
* `ujust bootstrap`
* `yadm decrypt`
* `yadm remote set-url origin git@github.com:aussielunix/dotfiles.git`
* `just update_aussielunix_ca`
* `just mytoolbx`
* `just owncloud_distrobox`
* `nmcli con import type wiregurard file $HOME/.config/wireguard/mgmt.conf`
* `rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aussielunix/mystation:latest` # not needed for offline installs
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

Some blue-build [docs](https://blue-build.org/learn/universal-blue/#fresh-install-from-an-iso) about generating an offline ISO of your latest published blue-build built image.

TL;DR - run the following:

```bash
sudo podman run --rm --privileged --volume ./iso-output:/build-container-installer/build --security-opt label=disable --pull=newer ghcr.io/jasonn3/build-container-installer:latest --env IMAGE_REPO=ghcr.io/aussielunix --env IMAGE_NAME=mystation --env IMAGE_TAG=40 --env VARIANT=Server --env VERSION=40
```
See the tools [README](https://github.com/JasonN3/build-container-installer/tree/main?tab=readme-ov-file#customizing) for possible build options.

**Note:** These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/aussielunix/mystation
```
