FROM debian:bookworm

ARG RDKIT_TAG=Release_2024_09_1

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
RUN curl -sfL https://github.com/goreleaser/nfpm/releases/download/v2.41.1/nfpm_2.41.1_linux_$(dpkg --print-architecture).deb -o /tmp/nfpm.deb \
    && dpkg -i /tmp/nfpm.deb \
    && rm /tmp/nfpm.deb

WORKDIR /work
COPY nfpm-lib.yaml nfpm-dev.yaml rdkit.pc.in build.sh ./

RUN ./build.sh "$RDKIT_TAG"
