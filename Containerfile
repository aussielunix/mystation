# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

FROM quay.io/fedora/fedora-bootc:43

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ./ctx/build.sh

COPY system_files /

LABEL org.opencontainers.image.title="Aussielunix Workstation"
LABEL org.opencontainers.image.authors="Mick Pollard <mick@aussielunix.io>"
LABEL org.opencontainers.image.licenses="GPL-3.0-only"
# Define required labels for this bootc image to be recognized as such.
LABEL containers.bootc 1
LABEL ostree.bootable 1

RUN rm -rf /var && \
  mkdir /var && \
  bootc container lint

