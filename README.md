# rdkit-debian

Debian packages of the RDKit C++ libraries for the [rdkit-rs](https://github.com/rdkit-rs) project. Produces `.deb` packages with shared libraries, headers, and pkg-config files pinned to specific RDKit releases.

## Packages

| Package | Contents |
|---------|----------|
| `librdkit-rs` | RDKit shared libraries (`.so` files) |
| `librdkit-rs-dev` | C++ headers and `rdkit.pc` pkg-config file |

## Supported Platforms

| Distro | Boost | Architectures |
|--------|-------|---------------|
| Debian 12 (Bookworm) | 1.74 | amd64, arm64 |

We standardize on Debian Bookworm to match [Quickwit's](https://quickwit.io) build and runtime images (`rust:bookworm` / `debian:bookworm-slim`).

## Usage

Download the `.deb` files from the [latest release](https://github.com/rdkit-rs/rdkit-debian/releases) and install:

```bash
# Runtime only (e.g. in a Docker image)
dpkg -i librdkit-rs_*.deb
apt-get install -f  # install missing dependencies

# For building rdkit-sys (headers + pkg-config)
dpkg -i librdkit-rs_*.deb librdkit-rs-dev_*.deb
apt-get install -f
```

Verify pkg-config works:

```bash
pkg-config --cflags --libs rdkit
```

## Building a New Release

Trigger the workflow manually from the Actions tab, providing the RDKit release tag:

```
RDKit release tag: Release_2024_09_1
```

The workflow builds RDKit from source inside a `debian:bookworm` container for both amd64 and arm64, packages the results with [nfpm](https://nfpm.goreleaser.com/), and uploads `.deb` artifacts.

## CMake Configuration

We build RDKit with a minimal C++-only configuration:

```bash
cmake .. \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DCMAKE_SKIP_RPATH=ON \
  -DRDK_BUILD_PYTHON_WRAPPERS=OFF \
  -DRDK_BUILD_JAVA_WRAPPERS=OFF \
  -DRDK_BUILD_CAIRO_SUPPORT=OFF \
  -DRDK_BUILD_PGSQL=OFF \
  -DRDK_INSTALL_INTREE=OFF \
  -DRDK_BUILD_INCHI_SUPPORT=ON \
  -DRDK_BUILD_THREADSAFE_SSS=ON \
  -DRDK_BUILD_COORDGEN_SUPPORT=OFF \
  -DRDK_BUILD_MAEPARSER_SUPPORT=OFF \
  -DRDK_BUILD_FREESASA_SUPPORT=OFF \
  -DRDK_BUILD_CPP_TESTS=OFF
```

Key flags:
- **`RDK_BUILD_THREADSAFE_SSS=ON`** — Critical for rdkit-rs, which uses rayon for parallel substructure search
- **`CMAKE_SKIP_RPATH=ON`** — Makes libraries relocatable for packaging
- **Coordgen/maeparser/freesasa disabled** — Avoids build-time downloads from GitHub and we don't wrap these in our CXX bindings

## Prior Art: Debian's Official RDKit Packages

The Debian debichem team maintains official RDKit packages at
[salsa.debian.org/debichem-team/rdkit](https://salsa.debian.org/debichem-team/rdkit).
They ship 6 binary packages (`python3-rdkit`, `rdkit-doc`, `rdkit-data`,
`librdkit1t64`, `librdkit-dev`, `postgresql-18-rdkit`) and maintain 14 patches
on top of upstream RDKit.

**Why we don't use theirs:**

- Debian/Ubuntu pin a single RDKit version per release (e.g. Ubuntu Jammy ships
  RDKit 202109). Our `rdkit-sys` CXX bindings are tightly coupled to specific
  RDKit C++ headers and we need to track upstream releases closely.
- Their packages include Python bindings, PostgreSQL cartridge, and documentation
  that we don't need. We only need the C++ shared libraries and headers.
- We need builds for architectures and distro versions on our timeline, not
  Debian's release cadence.

**What we learned from their packaging:**

- **Disable build-time downloads.** RDKit's CMake fetches dependencies at build
  time (coordgen, maeparser, Better Enums, RapidJSON). Debian patches these out
  for reproducibility. We disable the features that trigger downloads via CMake
  flags (`-DRDK_BUILD_COORDGEN_SUPPORT=OFF`, etc.) instead of maintaining patches.
- **Enable thread-safe substructure search.** `-DRDK_BUILD_THREADSAFE_SSS=ON` is
  critical — our Rust code runs parallel substructure searches via rayon.
- **Skip RPATH.** `-DCMAKE_SKIP_RPATH=ON` makes libraries relocatable for packaging.
- **InChI linking.** Depending on RDKit version, the InChI CMake variable name
  may need fixing (`INCHI_LIBRARIES` -> `INCHI_LIBRARY`). Test and patch if needed.
