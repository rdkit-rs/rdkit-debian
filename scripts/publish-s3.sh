#!/usr/bin/env bash
set -euo pipefail
bash scripts/s3-preflight.sh
curl --fail --location --retry 3 https://rubygems.org/downloads/deb-s3-26.1.0.gem -o /tmp/deb-s3-26.1.0.gem
printf '%s\n' '8beb36bd7d5f524644f2e4b947e9212bcb47cab0b50cd8ad459ce527f938b956  /tmp/deb-s3-26.1.0.gem' | sha256sum --check --strict
gem install --user-install --no-document /tmp/deb-s3-26.1.0.gem
export PATH="$(ruby -e 'puts Gem.user_dir')/bin:$PATH"
deb-s3 upload --bucket rdkit-rs-debian --s3-region eu-central-1 \
    --codename resolute --component main --preserve-versions --fail-if-exists \
    --visibility public --cache-control max-age=60 release/*.deb
for arch in amd64 arm64; do
    aws s3 cp "release/rdkit-2026.09.1-ubuntu26.04-$arch.tar.xz" \
        "s3://rdkit-rs-debian/releases/$GITHUB_REF_NAME/" --acl public-read --only-show-errors
done
aws s3 cp release/SHA256SUMS "s3://rdkit-rs-debian/releases/$GITHUB_REF_NAME/" --acl public-read --only-show-errors
curl --fail --silent --show-error https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com/dists/jammy/Release > /tmp/jammy-release-after
cmp /tmp/jammy-release-before /tmp/jammy-release-after
python3 scripts/verify-s3.py release
