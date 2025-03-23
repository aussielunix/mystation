#!/usr/bin/env sh

set -ouex pipefail

#sed -i '/^\[composefs\]/,/^\[/ s/enabled = no/enabled = yes/' /usr/lib/ostree/prepare-root.conf

sed -i 's,ExecStart=/usr/bin/bootc update --apply --quiet,ExecStart=/usr/bin/bootc update --quiet,g' \
  /usr/lib/systemd/system/bootc-fetch-apply-updates.service

