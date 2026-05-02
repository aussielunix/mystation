FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/silverblue-main:44

COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    ./ctx/build.sh

# Copy Homebrew files from the homebrew image
COPY --from=registry.gitlab.com/aussielunix/linux-ng/rnd/homebrew:edge /system_files /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    --mount=type=tmpfs,dst=/run \
    find /usr/lib/systemd/system -type d -exec chmod 0755 '{}' + && \
    find /usr/lib/systemd/system -type f -exec chmod 0600 '{}' + && \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer

LABEL containers.bootc 1
LABEL ostree.bootable 1

RUN bootc container lint --fatal-warnings --no-truncate
