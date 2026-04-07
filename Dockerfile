FROM debian:bookworm

ARG RDKIT_TAG
ARG BUILD_NUMBER

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    ca-certificates \
    libeigen3-dev \
    libboost-all-dev \
    rapidjson-dev \
    && rm -rf /var/lib/apt/lists/*

# Install nfpm
RUN curl -sfL https://github.com/goreleaser/nfpm/releases/download/v2.46.0/nfpm_2.46.0_$(dpkg --print-architecture).deb -o /tmp/nfpm.deb \
    && dpkg -i /tmp/nfpm.deb \
    && rm /tmp/nfpm.deb

WORKDIR /work
COPY nfpm-lib.yaml nfpm-dev.yaml rdkit.pc.in build.sh ./

RUN test -n "$RDKIT_TAG" || (echo "ERROR: RDKIT_TAG is required (e.g. --build-arg RDKIT_TAG=Release_2026_03_1)" && exit 1)
RUN test -n "$BUILD_NUMBER" || (echo "ERROR: BUILD_NUMBER is required (e.g. --build-arg BUILD_NUMBER=1)" && exit 1)
RUN ./build.sh "$RDKIT_TAG" "$BUILD_NUMBER"
