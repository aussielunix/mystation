# Allow build scripts to be referenced without being copied into the final image

FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/silverblue-main:42

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    ./ctx/05-workarounds.sh && \
    ./ctx/10-prep.sh && \
    ./ctx/20-repos.sh && \
    ./ctx/30-packages.sh && \
    ./ctx/40-brew.sh && \
    ./ctx/50-bootc.sh && \
    ./ctx/60-finalize.sh

COPY system_files /

RUN rm -rf /var && \
  mkdir /var && \
  bootc container lint
