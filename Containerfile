FROM quay.io/fedora/fedora-bootc:43 as builder
COPY build_files /
RUN /usr/libexec/bootc-base-imagectl build-rootfs --manifest=standard /target-rootfs

# Create a new, empty image from scratch.
FROM scratch
# Copy the root file system built in the previous step into this image.
COPY --from=builder /target-rootfs/ /
RUN --mount=type=bind,from=builder,source=/,target=/ctx \
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

STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
