RDKIT_TAG ?= Release_2024_09_1

build:
	docker build --build-arg RDKIT_TAG=$(RDKIT_TAG) -t rdkit-debian-build .

extract: build
	docker create --name rdkit-deb-extract rdkit-debian-build true 2>/dev/null || true
	docker cp rdkit-deb-extract:/work/librdkit-rs_*.deb .
	docker cp rdkit-deb-extract:/work/librdkit-rs-dev_*.deb .
	docker rm rdkit-deb-extract
	@echo ""
	@echo "Extracted packages:"
	@ls -lh *.deb

clean:
	rm -f *.deb
	docker rm rdkit-deb-extract 2>/dev/null || true

.PHONY: build extract clean
