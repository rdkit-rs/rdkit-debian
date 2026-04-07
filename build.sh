#!/usr/bin/env bash
set -euo pipefail

RDKIT_TAG="${1:?Usage: build.sh <rdkit-release-tag> [build-number] (e.g. Release_2026_03_1 1)}"
BUILD_NUMBER="${2:-1}"

# Derive version string: Release_2026_03_1 -> 2026.03.1
RDKIT_VERSION=$(echo "$RDKIT_TAG" | sed 's/^Release_//; s/_/./g')

# Detect architecture
DPKG_ARCH=$(dpkg --print-architecture)
case "$DPKG_ARCH" in
  amd64) MULTIARCH="x86_64-linux-gnu" ;;
  arm64) MULTIARCH="aarch64-linux-gnu" ;;
  *) echo "Unsupported architecture: $DPKG_ARCH"; exit 1 ;;
esac

echo "Building RDKit $RDKIT_VERSION-$BUILD_NUMBER ($RDKIT_TAG) for $DPKG_ARCH ($MULTIARCH)"

# Download and extract source
cd /tmp
curl -sL "https://github.com/rdkit/rdkit/archive/refs/tags/${RDKIT_TAG}.tar.gz" | tar xz
cd "rdkit-${RDKIT_TAG}"

# Build
mkdir -p build && cd build
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_SKIP_RPATH=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=OFF \
  -DRDK_BUILD_JAVA_WRAPPERS=OFF \
  -DRDK_BUILD_CAIRO_SUPPORT=OFF \
  -DRDK_BUILD_PGSQL=OFF \
  -DRDK_INSTALL_INTREE=OFF \
  -DRDK_BUILD_INCHI_SUPPORT=ON \
  -DRDK_BUILD_THREADSAFE_SSS=ON \
  -DRDK_BUILD_COORDGEN_SUPPORT=OFF \
  -DRDK_BUILD_MAEPARSER_SUPPORT=OFF \
  -DRDK_BUILD_FREESASA_SUPPORT=OFF \
  -DRDK_BUILD_FREETYPE_SUPPORT=OFF \
  -DRDK_INSTALL_COMIC_FONTS=OFF \
  -DRDK_BUILD_CPP_TESTS=OFF
make -j"$(nproc)"

SRCDIR="/tmp/rdkit-${RDKIT_TAG}"
BUILDDIR="${SRCDIR}/build"

# Prepare staging directory
WORKDIR="${GITHUB_WORKSPACE:-$(cd "$(dirname "$0")" && pwd)}"
STAGING="${WORKDIR}/staging"
rm -rf "$STAGING"
mkdir -p "$STAGING/usr/lib/pkgconfig" "$STAGING/usr/include"

# Stage shared libraries
cp -P "$BUILDDIR"/lib/libRDKit*.so* "$STAGING/usr/lib/"

# Stage headers (the Code/ directory contains all public headers)
cp -r "$SRCDIR/Code" "$STAGING/usr/include/rdkit"

# Generate pkg-config file
sed "s|@MULTIARCH@|${MULTIARCH}|g; s|@RDKIT_VERSION@|${RDKIT_VERSION}|g" \
  "$WORKDIR/rdkit.pc.in" > "$STAGING/usr/lib/pkgconfig/rdkit.pc"

# Export variables for nfpm
export RDKIT_VERSION BUILD_NUMBER ARCH="$DPKG_ARCH" MULTIARCH

# Package with nfpm
cd "$WORKDIR"
nfpm package --packager deb --config nfpm-lib.yaml --target "${WORKDIR}/"
nfpm package --packager deb --config nfpm-dev.yaml --target "${WORKDIR}/"

echo ""
echo "Built packages:"
ls -lh "$WORKDIR"/*.deb
