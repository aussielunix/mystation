#!/bin/bash

set -xeuo pipefail

# This is a bucket list. We want to not have anything in this file at all.

# https://github.com/ublue-os/image-template/issues/71
mkdir -m 0700 -p /var/roothome
mkdir -m 0700 -p /var/home
