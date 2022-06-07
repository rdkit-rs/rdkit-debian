FROM ubuntu:22.04

ARG RDKIT_VERSION=2022_03_2
ENV RDKIT_VERSION=$RDKIT_VERSION
ARG CC=/usr/bin/clang
ARG CXX=/usr/bin/clang++
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
ARG LD_LIBRARY_PATH=/usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN apt update -y && apt install sudo vim curl -y
RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt install -y --no-install-recommends tzdata
RUN apt-get install -y cmake clang llvm libclang-dev  make  git wget libboost-all-dev libfreetype6-dev libc6-dev-arm64-cross ca-certificates awscli dh-make debmake gem2deb npm2deb debhelper javahelper python3-pip
RUN pip3 install numpy
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-14 1000
RUN update-alternatives --install /usr/bin/cc  cc  /usr/bin/clang-14   1000
RUN mkdir coordgen
WORKDIR coordgen
RUN git clone https://github.com/schrodinger/coordgenlibs.git
WORKDIR coordgenlibs
RUN mkdir build
WORKDIR build
RUN cmake .. && make -j install
WORKDIR /
RUN git clone  https://github.com/rareylab/RingDecomposerLib.git
WORKDIR RingDecomposerLib
RUN mkdir build
WORKDIR build
RUN cmake .. -DCMAKE_BUILD_TYPE=Release && make && make -j10 install && cp /usr/local/lib/lib* /usr/lib
WORKDIR /

RUN wget https://github.com/rdkit/rdkit/archive/Release_2022_03_2.tar.gz && \
    cp Release_2022_03_2.tar.gz rdkit-sys-1.0.tar.gz && \
    rm Release_2022_03_2.tar.gz && \
    tar xzf rdkit-sys-1.0.tar.gz
RUN cp -r rdkit-Release_2022_03_2 rdkit-sys-1.0
RUN rm -r rdkit-Release_2022_03_2
WORKDIR rdkit-sys-1.0
RUN debmake -y -b',libsharedlib1,libsharedlib-dev' -e datascience@scientist.com -f 'Scientist'
RUN rm /rdkit-sys-1.0/debian/libsharedlib1.install
RUN rm /rdkit-sys-1.0/debian/libsharedlib1.symbols
RUN rm /rdkit-sys-1.0/debian/libsharedlib-dev.install
COPY debian/source /rdkit-sys-1.0/debian/source
COPY debian/compat /rdkit-sys-1.0/debian/compat
COPY debian/control /rdkit-sys-1.0/debian/control
COPY debian/rdkit-sys1.install /rdkit-sys-1.0/debian/rdkit-sys1.install
COPY debian/rdkit-sys1.symbols /rdkit-sys-1.0/debian/rdkit-sys1.symbols
COPY debian/rdkit-sys-dev.install /rdkit-sys-1.0/debian/rdkit-sys-dev.install
ARG CC=clang
ARG CXX=clang++
ENV CC=clang
ENV CXX=clang++
ARG RDBASE=/rdkit-sys-1.0
ENV RDBASE=/rdkit-sys-1.0
RUN debuild  --set-envvar=RDBASE=/rdkit-sys-1.0 --set-envvar=DEB_BUILD_OPTIONS=nocheck -j10
