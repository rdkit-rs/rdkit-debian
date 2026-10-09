#!/usr/bin/env bash
set -euo pipefail
[[ "$GITHUB_REF_NAME" == ubuntu-26.04-rdkit-2026.09.1-1 ]]
mkdir release
for arch in amd64 arm64; do
    dir="artifacts/rdkit-ubuntu26.04-$arch"
    (cd "$dir" && sha256sum --check SHA256SUMS)
    python3 - "$dir/provenance.json" "$GITHUB_SHA" "$arch" <<'PY'
import json
import sys
with open(sys.argv[1]) as handle:
    record = json.load(handle)
assert record['packaging_commit'] == sys.argv[2]
assert record['architecture'] == sys.argv[3]
assert record['version'] == '2026.09.1-1~ubuntu26.04'
PY
    cp "$dir"/*_"$arch".deb release/
    tar -cJf "release/rdkit-2026.09.1-ubuntu26.04-$arch.tar.xz" -C "$dir" .
done
cmp artifacts/rdkit-ubuntu26.04-{amd64,arm64}/rdkit-rs-data_2026.09.1-1~ubuntu26.04_all.deb
cp artifacts/rdkit-ubuntu26.04-amd64/*_all.deb release/
cp artifacts/rdkit-ubuntu26.04-amd64/{COPYRIGHT,sources.lock} release/
python3 scripts/checksums.py release
cat > release-notes.md <<EOFNOTES
RDKit 2026.09.1 built from upstream Release_2026_09_1 for Ubuntu 26.04 LTS.

Tested architectures: native AMD64 and ARM64. Packaging commit: $GITHUB_SHA.
Build and verification: https://github.com/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID

Install runtime, development and data packages with apt-get install ./package.deb.
Use the architecture-specific tar.xz bundle for the complete packages, original
source archives, Debian patches, copyright, build information, hashes and test logs.
The individual .deb files are also attached for convenience. Verify SHA256SUMS.

Runtime SONAME is .so.2026.09. Rust/C++ consumers need C++20. Development headers
conflict with Ubuntu's librdkit-dev; runtime and versioned data can coexist.
The tests cover pkg-config, CMake, chemical operations, data loading and a Rust
bridge fixture. Compatibility with the full rdkit-rs Rust crate is a separate test.
APT dependencies are recorded, not snapshot-pinned. Byte reproducibility has not
been measured. These are project reference packages, not Ubuntu archive packages.
EOFNOTES
