#!/bin/bash

set -xeuo pipefail

# This is a bucket list. We want to not have anything in this file at all.

# https://github.com/ublue-os/image-template/issues/71
mkdir -m 0700 -p /var/roothome
#mkdir -p /var/mnt
#mkdir -p /var/opt
#mkdir -p /var/srv
mkdir -m 0700 -p /var/home

# https://gitlab.com/fedora/bootc/base-images/-/issues/28
# https://github.com/containers/bootc/discussions/968#discussioncomment-11554946
#rm -rf /var/run && ln -s /run /var/

