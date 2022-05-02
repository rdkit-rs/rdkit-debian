FROM ubuntu:latest

ARG RDKIT_VERSION=2022_03_2
ENV RDKIT_VERSION=$RDKIT_VERSION

RUN apt-get update && \
    apt-get install -y build-essential cmake make git wget libboost-all-dev
RUN wget https://github.com/rdkit/rdkit/archive/refs/tags/Release_$RDKIT_VERSION.tar.gz -O /tmp/rdkit.tar.gz --quiet && \
    cd /tmp && tar xzf *.tar.gz && cd rdkit-* && \
    mkdir -p build && cd build && \
    cmake .. -D RDK_BUILD_PYTHON_WRAPPERS=OFF \
             -D RDK_OPTIMIZE_POPCNT=OFF \
             -D RDK_INSTALL_COMIC_FONTS=OFF \
             -D RDK_BUILD_FREETYPE_SUPPORT=OFF \
             -D RDK_INSTALL_STATIC_LIBS=ON \
             -D RDK_INSTALL_INTREE=OFF \
             -D RDK_BUILD_SWIG_JAVA_WRAPPER=OFF \
             -D RDK_BUILD_CPP_TESTS=OFF && \
    make install -j 10
    # move headers and libraries to a new folder \
    # run the debian process to put those in a *deb