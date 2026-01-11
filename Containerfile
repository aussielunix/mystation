FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/silverblue-main:43

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ./ctx/build.sh

COPY system_files /

# Copy Homebrew files from the homebrew image
COPY --from=registry.gitlab.com/aussielunix/linux-ng/rnd/homebrew:edge /system_files /
RUN --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /usr/bin/systemctl preset brew-setup.service && \
    /usr/bin/systemctl preset brew-update.timer && \
    /usr/bin/systemctl preset brew-upgrade.timer

LABEL containers.bootc 1
LABEL ostree.bootable 1

RUN rm -rf /var/lib/dnf && \
  rm -rf /var/lib/rpm-state && \
  bootc container lint --fatal-warnings
