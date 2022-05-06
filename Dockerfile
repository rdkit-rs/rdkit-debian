FROM ubuntu:latest

ARG RDKIT_VERSION=2022_03_2
ENV RDKIT_VERSION=$RDKIT_VERSION
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y dh-make gem2deb npm2deb wget git curl vim debmake tzdata build-essential libboost-all-dev cmake make debhelper
RUN wget https://github.com/rdkit/rdkit/archive/Release_$RDKIT_VERSION.tar.gz && \
    cp Release_2022_03_2.tar.gz rdkit-sys-1.0.tar.gz && \
    rm Release_2022_03_2.tar.gz && \
    tar xzf rdkit-sys-1.0.tar.gz
RUN cp -r rdkit-Release_2022_03_2 rdkit-sys-1.0
RUN rm -r rdkit-Release_2022_03_2
WORKDIR rdkit-sys-1.0
RUN debmake -y -b',libsharedlib1,libsharedlib-dev' -e datascience@scientist.com -f 'Scientist'
RUN rm debian/libsharedlib1.install
RUN rm debian/libsharedlib1.symbols
RUN rm debian/libsharedlib-dev.install

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