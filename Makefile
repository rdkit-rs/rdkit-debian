SHELL := /bin/bash

build:
	docker build --build-arg UBUNTU_IMAGE="$$(bash scripts/prepare-image.sh)" -t rdkit-resolute-builder .
	mkdir -p dist
	docker run --rm -e PACKAGING_COMMIT=$$(git rev-parse HEAD) -v "$(CURDIR)/dist:/out" rdkit-resolute-builder

check:
	docker run --rm -v "$(CURDIR):/packaging:ro" -v "$(CURDIR)/dist:/out" "$$(bash scripts/prepare-image.sh)" bash /packaging/scripts/test-install.sh

.PHONY: build check
