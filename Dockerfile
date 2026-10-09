ARG UBUNTU_IMAGE=ubuntu:26.04@sha256:f144425ff09be612d6d9ad965196e9cdc23dae1f42110a8a11a3e9a8198759f7
FROM ${UBUNTU_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake ninja-build debhelper pkgconf \
    libboost-dev libboost-serialization-dev libboost-iostreams-dev \
    libboost-program-options-dev libeigen3-dev libinchi-dev catch2 \
    ca-certificates curl git lintian python3 file \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /packaging
COPY . .
CMD ["./build.sh"]
