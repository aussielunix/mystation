# Allow build scripts to be referenced without being copied into the final image

FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/silverblue-main:43

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ./ctx/build.sh

COPY system_files /

# Copy Homebrew files from the brew image
COPY --from=registry.gitlab.com/aussielunix/linux-ng/rnd/homebrew:edge /system_files /

LABEL containers.bootc 1
LABEL ostree.bootable 1

RUN rm -rf /var && \
  mkdir /var && \
  bootc container lint
