# mystation [![build-mystation](https://github.com/aussielunix/mystation/actions/workflows/build.yml/badge.svg)](https://github.com/aussielunix/mystation/actions/workflows/build.yml)

This is my continually improved cloud native (Atomic) Desktop OS.  
Using bootc and other cloud native tools and workflows I can easily improve my
desktop over time.

It is based on the fantastic [template](https://github.com/ublue-os/image-template) from the [Universal Blue](https://universal-blue.org/) team.

## Firstboot Runsheet

* Check TIME & DATE
* Check HOSTNAME is a FQDN
* `just -l`
* `just bootstrap`
* `yadm decrypt`
* `yadm remote set-url origin git@github.com:aussielunix/dotfiles.git`
* `just update_aussielunix_ca`
* `just setup_vim`
* `just install_gnome_extensions`
* `just customize_gnome`
* `just install_flatpaks`
* `just prepare_firefox`
* `systemctl reboot`

## Installation

:TODO:

**Note:** These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/aussielunix/mystation
```
