#!/usr/bin/env bash
set -euo pipefail
: "${AWS_ACCESS_KEY_ID:?Existing repository AWS_ACCESS_KEY_ID secret is unavailable}"
: "${AWS_SECRET_ACCESS_KEY:?Existing repository AWS_SECRET_ACCESS_KEY secret is unavailable}"
[[ $(aws s3api get-bucket-location --bucket rdkit-rs-debian --query LocationConstraint --output text) == eu-central-1 ]]
aws s3api head-object --bucket rdkit-rs-debian --key dists/jammy/Release > /tmp/jammy-head.json
for suite in jammy resolute; do
    aws s3api list-objects-v2 --bucket rdkit-rs-debian --prefix "dists/$suite/" --output json > "/tmp/$suite-objects.json"
    python3 - "/tmp/$suite-objects.json" <<'PY'
import json
import sys
with open(sys.argv[1]) as handle:
    listing = json.load(handle)
for item in listing.get('Contents', []):
    if item['Key'].endswith(('/InRelease', '/Release.gpg')):
        raise SystemExit('Signed APT metadata exists; preserve its signing workflow before publishing.')
PY
done
curl --fail --silent --show-error https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com/dists/jammy/Release > /tmp/jammy-release-before
printf '%s\n' 'Verified existing rdkit-rs-debian bucket in eu-central-1; existing APT metadata is unsigned.'
