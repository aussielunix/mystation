# Allow build scripts to be referenced without being copied into the final image

FROM scratch AS ctx
COPY build_files /

#FROM ghcr.io/ublue-os/silverblue-main:42
FROM quay.io/fedora/fedora-bootc:42

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ./ctx/build.sh

COPY system_files /

RUN rm -rf /var && \
  mkdir /var && \
  bootc container lint
