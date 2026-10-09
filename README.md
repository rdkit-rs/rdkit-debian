# RDKit reference packages for Ubuntu 26.04

This repository packages upstream **RDKit 2026.09.1** for Ubuntu 26.04 LTS
(Resolute), using native AMD64 and ARM64 GitHub runners. Ubuntu's archive ships
RDKit `202503.6-4`; these packages build newer upstream source. They are project
reference builds, not Ubuntu archive packages.

| Package | Contents |
| --- | --- |
| `librdkit-rs202609` | C++ shared libraries with SONAME `2026.09` |
| `librdkit-rs-dev` | Installed C++ headers, linker symlinks, CMake targets and `rdkit.pc` |
| `rdkit-rs-data` | Data under `/usr/share/rdkit-rs/2026.09/Data` |

The package version is `2026.09.1-1~ubuntu26.04`. Development packages depend on
exactly matching runtime packages; runtime dependencies are calculated from ELF
objects by `dpkg-shlibdeps`, including Ubuntu's Boost and InChI libraries.
The development package conflicts with Ubuntu's `librdkit-dev` and the old
`librdkit-rs` bundle because they own the same headers or linker symlinks.
The versioned runtime and data can coexist with Ubuntu's runtime and data.
Applications built against the older C++ ABI must be rebuilt.

## Install and use

Download and extract the complete bundle for your architecture from this repository's
[GitHub Actions](https://github.com/rdkit-rs/rdkit-debian/actions/workflows/build.yml)
artifacts or [releases](https://github.com/rdkit-rs/rdkit-debian/releases),
including `SHA256SUMS`. The release `tar.xz` bundles and Actions artifacts include
all files needed for the checksum command below.

```bash
sha256sum --check SHA256SUMS
sudo apt-get update
sudo apt-get install ./rdkit-rs-data_2026.09.1-1~ubuntu26.04_all.deb \
  ./librdkit-rs202609_2026.09.1-1~ubuntu26.04_$(dpkg --print-architecture).deb \
  ./librdkit-rs-dev_2026.09.1-1~ubuntu26.04_$(dpkg --print-architecture).deb
pkg-config --modversion rdkit
export RDBASE=$(pkg-config --variable=rdbase rdkit)
c++ consumer.cpp $(pkg-config --cflags --libs rdkit) -o consumer
```

Runtime-only deployments need the runtime and data packages. `apt-get install
./file.deb` resolves dependencies, unlike `dpkg -i` alone. The existing S3 APT repository is also a publication target. PPA publication
and Ubuntu/Debian archive submission are outside this release.

CMake consumers use `find_package(rdkit CONFIG REQUIRED)` and imported targets
such as `RDKit::SmilesParse`; compile consumers as C++20. Rust bridge builds must
also use C++20 and discover include/link flags through `pkg-config rdkit`.
Upstream 2026.09 changes C++ interfaces, so a working package does not establish
compatibility with every released Rust binding version. The included Rust fixture
compiles a C++ bridge from the installed package and executes it through Cargo;
it is not the full `rdkit-rs/rdkit` regression suite.

## Build and verify

`make build` builds in the digest-pinned Ubuntu 26.04 image and writes packages,
Debian source packages, `.buildinfo`, `.changes`, dependency versions, copyright,
provenance and checksums to `dist/`. `make check` installs them into a fresh image
and tests C++ pkg-config/CMake linkage, molecular operations, data loading and
Rust linkage. The local container host architecture determines the build;
ARM64 CI uses `ubuntu-24.04-arm`, and AMD64 CI uses `ubuntu-24.04`. Host runner
versions do not determine the package's target OS.

CI builds from the checked-out commit, pins action revisions, checks packages
with Lintian and metadata/ELF assertions, then installs in a separate clean
Ubuntu 26.04 container. The compile stage runs without network after verified
sources and dependencies have been fetched. The release job only publishes
after both native architectures pass. Its tag identifies the explicit committed
packaging ref. Source PRs do not need to be merged to run the branch workflow.

`sources.lock` records the upstream tag, commit, archive checksums, dependency
sources and container digest. `build-packages.tsv` and `.buildinfo` record the
actual APT toolchain. APT repositories can change: this is a pinned source and
base-image build, **not a claim of measured byte reproducibility**. Rebuilding
an upstream version requires a packaging revision bump, refreshed checksums,
review of the patches, licenses and tested dependency versions.

## Scope and packaging choices

The existing project recipe targeted Debian Bookworm with nfpm. Its manually
copied headers, hard-coded Boost dependency and unversioned RDKit ABI were
insufficient for a newer Ubuntu reference. This recipe uses a small debhelper
source package: CMake performs installation, Debian generates shared-library
dependencies and `ldconfig` triggers, and `dh_missing` rejects unassigned files.

RDKit's upstream `.so.1` does not distinguish these C++ releases. The packaging
patch gives this release series `.so.2026.09`, fixes CMake's prefix calculation
for multiarch library directories, uses versioned data, and adapts the InChI
version helper to Ubuntu's public system headers. No chemical algorithms are
changed by packaging. Upstream's mandatory RingDecomposerLib source performs its
own stable-sort adaptation at configure time; the full dependency source is
included in the source package.

C++ support includes thread-safe substructure search, molecular standardization,
fingerprints, descriptors and system InChI, which the previous recipe enabled.
Python, Java, PostgreSQL, static libraries, graphics integrations, ChemDraw,
PubChem shape, CoordGen, MaeParser and FreeSASA are disabled. They are not required
by this reference's Rust use. Generic CPU flags avoid assuming the build runner's
instruction set. The complete upstream C++ test suite is not run; focused
installed-package tests establish this package's narrower contract.

## Lessons from the original write-up

The original [Forking a Debian Package article](https://github.com/rdkit-rs/rdkit-rs.github.io/blob/1d3778e6747e370bf628cbe6792b5e2dcf6945f4/content/tutorials/forking-a-debian-package.md)
was removed from the current site during its redesign; it remains in site history.
It describes Jammy's frozen RDKit, `gbp` and pristine-tar conventions, host versus
chroot dependency confusion, missing universe packages, PostgreSQL 14/15 control
file coupling, QEMU overhead and S3 repository publication. The useful principles
remain: isolate builds, keep dependency resolution real, learn from Debichem,
build publishable binaries in auditable CI and prefer native architectures.
The reference follows those principles with fewer components and existing free
native GitHub runners. S3 publication reuses the repository's existing GitHub OIDC publishing role.

## Licensing and maintenance

The Debian copyright inventory is adapted from Ubuntu's `202503.6-4` source
packaging, with notices for the pinned RingDecomposerLib (BSD-3-Clause) and
Better Enums (BSD-2-Clause). Original license texts accompany each binary package;
upstream data retains its own notices. RDKit is predominantly BSD-3-Clause but
contains other permissively licensed code and generated parsers with Bison's
exception. Do not describe the entire source archive as one license.
All three original source archives and the packaging/patch archive accompany
binaries, alongside their `.dsc` and hashes. System dependencies retain their
Ubuntu package licensing; they are not silently bundled into the RDKit package.

Maintenance consists of checking upstream C++/ABI changes, refreshing source and
image pins, adapting the small CMake patch, reviewing bundled licenses, rerunning
the native CI matrix and updating Rust consumer tests when the bindings change.
The package does not promise ABI stability across RDKit release series. A future
series needs its own runtime package and SONAME before publication.

## Existing S3 APT repository

The verified repository is `rdkit-rs-debian` in `eu-central-1`, defined by the
project's existing Terraform and historical tutorial. CI adds the `resolute/main`
suite at <https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com>. Publication uses
the existing `gha-rdkit-debian` OIDC role, verified in the historical
[`build-debs.yml`](https://github.com/rdkit-rs/rdkit-debian/blob/ca2f64008ec49831d1e62891b10745301d6efd6d/.github/workflows/build-debs.yml)
and project Terraform. The newer Bookworm workflow's static-key references were
empty in the live CI check; no new key or IAM policy is created. It preserves existing package versions and the Jammy suite; it never
uses bucket synchronization with deletion or changes bucket security settings.

The historical repository uses unsigned Release metadata and `trusted=yes`.
This is the existing trust model: HTTPS protects transport, but APT does not
verify a repository signature. CI checks the authenticated bucket listing and
stops if signed metadata exists, rather than replacing it with unsigned metadata.
No new signing key is created. To use that existing trust model after publication:

```bash
echo "deb [arch=$(dpkg --print-architecture) trusted=yes] https://rdkit-rs-debian.s3.eu-central-1.amazonaws.com resolute main" | sudo tee /etc/apt/sources.list.d/rdkit-rs.list
sudo apt-get update
sudo apt-get install librdkit-rs-dev=2026.09.1-1~ubuntu26.04
```

A single CI publication job serializes updates to this suite, uses pinned
`deb-s3` with version preservation and refuses different bytes for an existing
package filename. Post-publication jobs download and install through APT on both
native architectures, and independently verify downloaded package hashes against
the tested release assets. Source/provenance bundles are retained under
`releases/<release-tag>/` in the same bucket and on the GitHub release.
