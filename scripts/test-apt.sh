#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends ca-certificates
printf 'deb [arch=%s trusted=yes] https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com resolute main\n' "$(dpkg --print-architecture)" > /etc/apt/sources.list.d/rdkit-rs.list
apt-get update
apt-get install -y --no-install-recommends librdkit-rs-dev=2026.09.1+ds1-1~ubuntu26.04
for name in librdkit-rs202609 librdkit-rs-dev rdkit-rs-data; do
    [[ $(dpkg-query -W -f='${Version}' "$name") == 2026.09.1+ds1-1~ubuntu26.04 ]]
done
mkdir /out
cd /out
apt-get download librdkit-rs202609=2026.09.1+ds1-1~ubuntu26.04 librdkit-rs-dev=2026.09.1+ds1-1~ubuntu26.04 rdkit-rs-data=2026.09.1+ds1-1~ubuntu26.04
bash /packaging/scripts/test-install.sh
