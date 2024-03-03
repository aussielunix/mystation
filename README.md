# mystation - A continually improved Cloud Native Desktop OS.

This is built using the [Blue Build](https://blue-build.org/) [template](https://github.com/blue-build/template) repo.

[![build-mystation](https://github.com/aussielunix/mystation/actions/workflows/build.yml/badge.svg)](https://github.com/aussielunix/mystation/actions/workflows/build.yml)

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
* `systemctl reboot`
* log into ownCloud
* enter into mytoolbox and run `brew bundle install`

**Work out firefox not trusting my cacert**
- https://bgstack15.wordpress.com/2018/10/04/firefox-trust-system-trusted-certificates/

## Customization

The easiest way to start customizing is by looking at and modifying `config/recipe.yml`. It's documented using comments and should be pretty easy to understand.  
For more information about customization, see the Blue Build [docs](https://blue-build.org/learn/getting-started/)

## Installation

To rebase an existing Silverblue/Kinoite installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/aussielunix/mystation:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aussielunix/mystation:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

This repository builds date tags as well, so if you want to rebase to a particular day's build:

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/aussielunix/mystation:39-20230403
```

This repository by default also supports signing.

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

This template includes a simple Github Action to build and release an ISO of your image. 

To run the action, simply edit the `boot_menu.yml` by changing all the references to startingpoint to your repository. This should trigger the action automatically.

The Action uses [isogenerator](https://github.com/ublue-os/isogenerator) and works in a similar manner to the official Universal Blue ISO. If you have any issues, you should first check [the documentation page on installation](https://universal-blue.org/installation/). The ISO is a netinstaller and should always pull the latest version of your image.

Note that this release-iso action is not a replacement for a full-blown release automation like [release-please](https://github.com/googleapis/release-please).

