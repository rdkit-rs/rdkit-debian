SHELL := /bin/bash

build:
	docker build -t rdkit-resolute-builder .
	mkdir -p dist
	docker run --rm -e PACKAGING_COMMIT=$$(git rev-parse HEAD) -v "$(CURDIR)/dist:/out" rdkit-resolute-builder

check:
	docker run --rm -v "$(CURDIR):/packaging:ro" -v "$(CURDIR)/dist:/out" "$$(. ./sources.lock; echo $$UBUNTU_IMAGE)" bash /packaging/scripts/test-install.sh

.PHONY: build check
