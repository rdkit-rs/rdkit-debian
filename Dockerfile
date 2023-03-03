FROM ubuntu:22.04

ARG RDKIT_VERSION=2022_09_3
ENV RDKIT_VERSION=$RDKIT_VERSION
ARG CC=/usr/bin/clang
ARG CXX=/usr/bin/clang++
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++
ARG LD_LIBRARY_PATH=/usr/local/lib
ENV LD_LIBRARY_PATH=/usr/local/lib

RUN apt update -y && apt install sudo vim curl -y
RUN DEBIAN_FRONTEND=noninteractive apt update -y && apt install -y --no-install-recommends tzdata
RUN apt-get install -y cmake clang llvm libclang-dev  make  git wget libboost-all-dev libfreetype6-dev ca-certificates awscli dh-make debmake gem2deb npm2deb debhelper javahelper python3-pip
RUN pip3 install numpy
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++-14 1000
RUN update-alternatives --install /usr/bin/cc  cc  /usr/bin/clang-14   1000
WORKDIR /

RUN wget https://github.com/rdkit/rdkit/archive/Release_2022_09_3.tar.gz && \
    cp Release_2022_09_3.tar.gz rdkit-2022.9.3.tar.gz && \
    rm Release_2022_09_3.tar.gz && \
    tar xzf rdkit-2022.9.3.tar.gz
RUN cp -r rdkit-Release_2022_09_3 rdkit-2022.9.3
RUN rm -r rdkit-Release_2022_09_3
WORKDIR rdkit-2022.9.3
RUN debmake -y -b',libsharedlib1,libsharedlib-dev' -e maria.dubyaga@scientist.com -f 'Maria Dubyaga'
RUN rm /rdkit-2022.9.3/debian/libsharedlib*
COPY debian/source /rdkit-2022.9.3/debian/source
COPY debian/compat /rdkit-2022.9.3/debian/compat
COPY debian/control /rdkit-2022.9.3/debian/control
COPY debian/rdkit1.install /rdkit-2022.9.3/debian/rdkit1.install
COPY debian/rdkit-dev.install /rdkit-2022.9.3/debian/rdkit-dev.install
ARG CC=clang
ARG CXX=clang++
ENV CC=clang
ENV CXX=clang++
ARG RDBASE=/rdkit-2022.9.3
ENV RDBASE=/rdkit-2022.9.3
RUN debuild  --set-envvar=RDBASE=/rdkit-2022.9.3 --set-envvar=DEB_BUILD_OPTIONS=nocheck -S -j10 --no-lintian --no-sign
