#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
source "$root/sources.lock"
source /etc/os-release
[[ "$ID" == ubuntu && "$VERSION_ID" == 26.04 ]]
mode=${1:-all}
work=${BUILD_ROOT:-/build}
out=${OUTPUT_DIR:-/out}
source_dir="$work/rdkit-rs-$RDKIT_VERSION"
mkdir -p "$work" "$out"
fetch() {
    local url=$1 file=$2 checksum=$3
    if [[ ! -f "$work/$file" ]]; then
        curl --fail --location --retry 3 "$url" -o "$work/$file"
    fi
    printf '%s  %s\n' "$checksum" "$work/$file" | sha256sum --check --strict
}
if [[ "$mode" == all || "$mode" == prepare ]]; then
    [[ ! -e "$source_dir" ]]
    fetch "https://codeload.github.com/rdkit/rdkit/tar.gz/refs/tags/$RDKIT_TAG" "rdkit-rs_$RDKIT_VERSION.orig.tar.gz" "$RDKIT_SHA256"
    fetch "https://codeload.github.com/rareylab/RingDecomposerLib/tar.gz/refs/tags/$RING_TAG" "rdkit-rs_$RDKIT_VERSION.orig-ringdecomposer.tar.gz" "$RING_SHA256"
    fetch "https://codeload.github.com/aantron/better-enums/tar.gz/$ENUMS_COMMIT" "rdkit-rs_$RDKIT_VERSION.orig-better-enums.tar.gz" "$ENUMS_SHA256"
    mkdir -p "$source_dir" "$source_dir/ringdecomposer" "$source_dir/better-enums"
    tar xf "$work/rdkit-rs_$RDKIT_VERSION.orig.tar.gz" --strip-components=1 -C "$source_dir"
    tar xf "$work/rdkit-rs_$RDKIT_VERSION.orig-ringdecomposer.tar.gz" --strip-components=1 -C "$source_dir/ringdecomposer"
    tar xf "$work/rdkit-rs_$RDKIT_VERSION.orig-better-enums.tar.gz" --strip-components=1 -C "$source_dir/better-enums"
    cp -a "$root/debian" "$source_dir/debian"
    cp "$root/sources.lock" "$source_dir/debian/sources.lock"
    mkdir -p "$source_dir/debian/licenses"
    cp "$source_dir/license.txt" "$source_dir/debian/licenses/RDKit.txt"
    cp "$source_dir/ringdecomposer/LICENSE" "$source_dir/debian/licenses/RingDecomposerLib.txt"
    cp "$source_dir/better-enums/LICENSE.md" "$source_dir/debian/licenses/BetterEnums.txt"
    cp "$root/README.md" "$source_dir/debian/README.reference"
    for package in librdkit-rs202609 librdkit-rs-dev rdkit-rs-data; do
        printf 'debian/licenses\ndebian/sources.lock\ndebian/README.reference\n' > "$source_dir/debian/$package.docs"
    done
fi
if [[ "$mode" == all || "$mode" == build ]]; then
    cd "$source_dir"
    dpkg-buildpackage --no-sign -sa -j"${BUILD_JOBS:-4}"
    cp "$work"/*.deb "$work"/*.dsc "$work"/*.tar.* "$work"/*.buildinfo "$work"/*.changes "$out/"
    dpkg-query -W -f='${binary:Package}\t${Version}\n' > "$out/build-packages.tsv"
    cp "$root/sources.lock" "$out/sources.lock"
    cp debian/copyright "$out/COPYRIGHT"
    cp "$root/README.md" "$out/README.md"
    packaging_commit=${PACKAGING_COMMIT:-$(git -C "$root" rev-parse HEAD)}
    export packaging_commit RDKIT_COMMIT RDKIT_TAG RDKIT_SHA256 UBUNTU_IMAGE
    python3 "$root/scripts/provenance.py" "$out/provenance.json"
    python3 "$root/scripts/checksums.py" "$out"
fi
[[ "$mode" == all || "$mode" == prepare || "$mode" == build ]]
