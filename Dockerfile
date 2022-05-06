FROM ubuntu:latest

ARG RDKIT_VERSION=2022_03_2
ENV RDKIT_VERSION=$RDKIT_VERSION
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y dh-make gem2deb npm2deb wget git curl vim debmake tzdata build-essential libboost-all-dev cmake make debhelper
RUN wget wget https://github.com/rdkit/rdkit/archive/Release_$RDKIT_VERSION.tar.gz && \
    mv Release_2022_03_2.tar.gz rdkit-sys-1.0.tar.gz && \
    tar xzf rdkit-sys-1.0.tar.gz && \
    mv rdkit-Release_2022_03_2 rdkit-sys-1.0 && \
    cd rdkit-sys-1.0 && \
    debmake -b',rdkit-sys1,rdkit-sys-dev' -e datascience@scientist.com -f 'Scientist'

COPY /debian/source /rdkit-sys-1.0/debian/source
COPY /debian/compat /rdkit-sys-1.0/debian/compat
COPY /debian/control /rdkit-sys-1.0/debian/control
COPY /debian/rdkit-sys1.install /rdkit-sys-1.0/debian/rdkit-sys1.install
COPY /debian/rdkit-sys1.symbols /rdkit-sys-1.0/debian/rdkit-sys1.symbols
COPY /debian/rdkit-sys-dev.install /rdkit-sys-1.0/debian/rdkit-sys-dev.install

WORKDIR /rdkit-sys-1.0
RUN debuild

    # move headers and libraries to a new folder \
    # run the debian process to put those in a *deb