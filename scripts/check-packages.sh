#!/usr/bin/env bash
set -euo pipefail
out=${1:-/out}
arch=$(dpkg --print-architecture)
version=2026.09.1+ds1-1~ubuntu26.04
for package in librdkit-rs202609 librdkit-rs-dev rdkit-rs-data; do
    expected_arch=$arch
    [[ "$package" != rdkit-rs-data ]] || expected_arch=all
    file="$out/${package}_${version}_${expected_arch}.deb"
    [[ $(dpkg-deb -f "$file" Package) == "$package" ]]
    [[ $(dpkg-deb -f "$file" Version) == "$version" ]]
    [[ $(dpkg-deb -f "$file" Architecture) == "$expected_arch" ]]
    dpkg-deb --info "$file"
done
lintian --allow-root --fail-on error "$out"/*.deb "$out"/*.dsc
