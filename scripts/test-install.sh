#!/usr/bin/env bash
set -euo pipefail
source /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 26.04 ]]
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends /out/rdkit-rs-data_*.deb /out/librdkit-rs202609_*.deb
multiarch=$(dpkg --print-architecture)
case "$multiarch" in
    amd64) triplet=x86_64-linux-gnu ;;
    arm64) triplet=aarch64-linux-gnu ;;
    *) exit 1 ;;
esac
for lib in /usr/lib/"$triplet"/libRDKit*.so.2026.09; do
    ldd -r "$lib" > /tmp/rdkit-ldd.txt 2>&1
    if grep -E 'not found|undefined symbol' /tmp/rdkit-ldd.txt; then exit 1; fi
done
apt-get install -y --no-install-recommends librdkit1t64 /out/librdkit-rs-dev_*.deb g++ cmake pkgconf cargo
[[ $(pkg-config --modversion rdkit) == 2026.09.1 ]]
export RDBASE=$(pkg-config --variable=rdbase rdkit)
test -f "$RDBASE/Data/BaseFeatures.fdef"
test -f /usr/include/rdkit/GraphMol/ROMol.h
test -f /usr/include/rdkit/RDGeneral/RDConfig.h
for lib in /usr/lib/"$triplet"/libRDKit*.so.2026.09; do
    readelf -d "$lib" > /tmp/rdkit-elf.txt
    grep -E 'SONAME.*\.so\.2026\.09\]' /tmp/rdkit-elf.txt
    if grep -E 'RPATH|RUNPATH' /tmp/rdkit-elf.txt; then exit 1; fi
done
cp -r /packaging/tests /tmp/rdkit-tests
cd /tmp/rdkit-tests
c++ main.cpp bridge.cpp $(pkg-config --cflags --libs rdkit) -lRDKitMolChemicalFeatures -o pkg-config-consumer
./pkg-config-consumer
cmake -S . -B cmake-build
cmake --build cmake-build --parallel 2
./cmake-build/consumer
cd rust-consumer
cargo test --offline
cargo run --offline
ldd target/debug/rdkit-package-consumer
if ldd target/debug/rdkit-package-consumer | grep -E 'libRDKit.*\.so\.1([[:space:]]|$)|not found'; then exit 1; fi
dpkg-query -W librdkit-rs202609 librdkit-rs-dev rdkit-rs-data
