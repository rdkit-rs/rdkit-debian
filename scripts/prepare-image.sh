#!/usr/bin/env bash
set -euo pipefail
source sources.lock
for candidate in "$UBUNTU_IMAGE" "$UBUNTU_MIRROR"; do
    if docker image inspect "$candidate" >/dev/null 2>&1 || docker pull "$candidate" >&2; then
        printf '%s\n' "$candidate"
        exit 0
    fi
done
exit 1
