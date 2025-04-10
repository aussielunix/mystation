FROM ghcr.io/ublue-os/silverblue-main:42

WORKDIR /workdir

COPY build_files .

RUN ./05-workarounds.sh \
  && ./10-prep.sh \
  && ./20-repos.sh \
  && ./30-packages.sh \
  && ./40-brew.sh \
  && ./50-bootc.sh \
  && ./60-finalize.sh

WORKDIR /

COPY system_files /

RUN rm -rdf /workdir
RUN bootc container lint
