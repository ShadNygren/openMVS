# =============================================================================
# OpenMVS Docker Image — Multi-Stage Build
# =============================================================================
# Builds OpenMVS v2.4.0+ from source on Ubuntu 26.04 with optional CUDA support.
#
# OpenMVS is licensed under AGPL-3.0. See LICENSE and COPYRIGHT.md in the
# repository root for full license terms and third-party notices.
#
# Dockerfile and Docker build infrastructure:
#   Copyright (c) 2026 Shad Nygren, Virtual Hipster Corporation
#   Licensed under AGPL-3.0 (same as OpenMVS, per AGPL-3.0 Section 5)
#
# Usage:
#   CPU-only:  docker build -t openmvs .
#   With CUDA: docker build --build-arg CUDA=1 \
#                --build-arg BASE_IMAGE=nvidia/cuda:12.9.1-devel-ubuntu24.04 \
#                --build-arg RUNTIME_IMAGE=nvidia/cuda:12.9.1-runtime-ubuntu24.04 \
#                -t openmvs-cuda .
#
# NOTE: CUDA variant still uses Ubuntu 24.04 base (no nvidia/cuda 26.04 images yet).
#       CPU-only defaults to Ubuntu 26.04 (Boost 1.90, CGAL 6.1 from apt).
#       OpenCV 4.10 still compiled from source (Ubuntu's package lacks JPEGXL codec).
#
# SBOM: see docker/SBOM.md for full Software Bill of Materials
# =============================================================================

# -- Configurable base images ------------------------------------------------
ARG BASE_IMAGE=ubuntu:26.04
ARG RUNTIME_IMAGE=ubuntu:26.04

# =============================================================================
# Stage 1: Builder — compile all dependencies and OpenMVS from source
# =============================================================================
FROM ${BASE_IMAGE} AS builder

ARG CUDA=0
ARG OPENMVS_BRANCH=develop

LABEL stage=builder
LABEL org.opencontainers.image.source="https://github.com/ShadNygren/openMVS"

ENV DEBIAN_FRONTEND=noninteractive

# -- System build dependencies (single layer, sorted, no-install-recommends) --
# Ubuntu 26.04 ships CGAL 6.1, Boost 1.90, nanoflann 1.9 from apt.
# OpenCV must be compiled from source — Ubuntu's package lacks JPEGXL codec.
RUN apt-get update -yq && apt-get install -yq --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    git \
    libjpeg-dev \
    libjxl-dev \
    libnanoflann-dev \
    libpng-dev \
    libtiff-dev \
    libexiv2-dev \
    pkg-config \
    # Boost
    libboost-iostreams-dev \
    libboost-program-options-dev \
    libboost-serialization-dev \
    libboost-system-dev \
    libboost-thread-dev \
    # OpenCV build deps (Ubuntu's 4.10 package lacks JPEGXL codec support)
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    # CGAL 6.1 (header-only, from Ubuntu 26.04 packages)
    libcgal-dev \
    # CGAL dependencies
    libgmp-dev \
    libmpfr-dev \
    zlib1g-dev \
    # OpenGL (for Viewer, optional)
    libglu1-mesa-dev \
    libglew-dev \
    libglfw3-dev \
    # Python bindings
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# -- Eigen 3.4 (header-only, from source for CUDA compatibility) -------------
RUN git clone --depth 1 --branch 3.4 https://gitlab.com/libeigen/eigen.git \
    && cmake -S eigen -B eigen_build \
        $([ "$CUDA" = "1" ] && echo "-DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda/") \
    && cmake --build eigen_build --target install \
    && rm -rf eigen eigen_build

# -- OpenCV 4.11.0 (from source — cv::IMWRITE_JPEGXL_QUALITY added in 4.11) --
# Ubuntu 26.04 ships OpenCV 4.10 which lacks JPEGXL write support.
RUN git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv.git \
    && cmake -S opencv -B opencv_build \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_LIST=core,imgproc,imgcodecs,features2d,calib3d,highgui,flann \
        -DWITH_JPEG=ON -DWITH_PNG=ON -DWITH_TIFF=ON -DWITH_JPEGXL=ON \
        -DWITH_EIGEN=ON -DEIGEN_INCLUDE_PATH=/usr/local/include/eigen3 \
        -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF \
        -DBUILD_opencv_apps=OFF -DBUILD_DOCS=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DCMAKE_INSTALL_PREFIX=/usr/local \
    && cmake --build opencv_build --parallel "$(nproc)" \
    && cmake --install opencv_build \
    && rm -rf opencv opencv_build

# -- VCGlib (header-only mesh library) ----------------------------------------
RUN git clone --depth 1 https://github.com/cdcseacave/VCG.git /vcglib

# -- OpenMVS (the main build) ------------------------------------------------
# Use the repo's own source tree (COPY . instead of git clone) so the image
# builds from the exact commit being worked on, not whatever is on GitHub.
COPY . /build/openMVS

RUN cmake -S openMVS -B openMVS_build \
        -DCMAKE_BUILD_TYPE=Release \
        -DVCG_ROOT=/vcglib \
        -DOpenMVS_USE_CUDA=$([ "$CUDA" = "1" ] && echo "ON" || echo "OFF") \
        $([ "$CUDA" = "1" ] && echo "\
            -DCMAKE_LIBRARY_PATH=/usr/local/cuda/lib64/stubs/ \
            -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda/ \
            -DCUDA_INCLUDE_DIRS=/usr/local/cuda/include/ \
            -DCUDA_CUDART_LIBRARY=/usr/local/cuda/lib64 \
            -DCUDA_CUDA_LIBRARY=/usr/local/cuda/lib64/stubs/libcuda.so \
            -DCMAKE_CUDA_ARCHITECTURES=80;86;89;90 \
            -DEIGEN3_INCLUDE_DIR=/usr/local/include/eigen3") \
    && cmake --build openMVS_build --parallel "$(nproc)" \
    && cmake --install openMVS_build \
    && rm -rf openMVS_build /vcglib

# =============================================================================
# Stage 2: Runtime — minimal image with only runtime dependencies
# =============================================================================
FROM ${RUNTIME_IMAGE} AS runtime

ARG CUDA=0

LABEL maintainer="ShadNygren <shad@hipster.net>"
LABEL org.opencontainers.image.title="OpenMVS"
LABEL org.opencontainers.image.description="Open Multi-View Stereo reconstruction library"
LABEL org.opencontainers.image.source="https://github.com/ShadNygren/openMVS"
LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.vendor="ShadNygren"

ENV DEBIAN_FRONTEND=noninteractive

# -- Runtime libraries only (no -dev packages, no compilers) ------------------
# Ubuntu 26.04: Boost 1.90, libjxl 0.11. OpenCV copied from builder (source build).
RUN apt-get update -yq && apt-get install -yq --no-install-recommends \
    ca-certificates \
    libboost-iostreams1.90.0 \
    libboost-program-options1.90.0 \
    libboost-serialization1.90.0 \
    libgmp10 \
    libmpfr6 \
    libgomp1 \
    libglu1-mesa \
    libglew2.2 \
    libglfw3 \
    libpng16-16t64 \
    libjpeg-turbo8 \
    libtiff6 \
    libjxl0.11 \
    python3 \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# -- Copy built binaries and libraries from builder --------------------------
COPY --from=builder /usr/local/bin/OpenMVS/ /usr/local/bin/OpenMVS/
COPY --from=builder /usr/local/lib/libMVS* /usr/local/lib/
COPY --from=builder /usr/local/lib/libCommon* /usr/local/lib/
COPY --from=builder /usr/local/lib/libIO* /usr/local/lib/
COPY --from=builder /usr/local/lib/libMath* /usr/local/lib/
COPY --from=builder /usr/local/lib/libopencv* /usr/local/lib/

# -- Legal notices, documentation, and examples (AGPL-3.0 requires this) -----
COPY --from=builder /build/openMVS/LICENSE /usr/share/doc/openmvs/LICENSE
COPY --from=builder /build/openMVS/COPYRIGHT.md /usr/share/doc/openmvs/COPYRIGHT.md
COPY --from=builder /build/openMVS/README.md /usr/share/doc/openmvs/README.md
COPY --from=builder /build/openMVS/docs/ /usr/share/doc/openmvs/docs/
COPY --from=builder /build/openMVS/docker/SBOM.md /usr/share/doc/openmvs/SBOM.md
COPY --from=builder /build/openMVS/docker/README.md /usr/share/doc/openmvs/DOCKER.md

# Refresh shared library cache
RUN ldconfig

# -- Python venv (PEP 668 compliance on Ubuntu 26.04) ------------------------
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:/usr/local/bin/OpenMVS:$PATH"

# -- Non-root user for security ----------------------------------------------
# Ubuntu 26.04 ships with 'ubuntu' user (UID/GID 1000) — reuse it
# -- Working directory --------------------------------------------------------
RUN mkdir -p /data && chown ubuntu:ubuntu /data
WORKDIR /data

USER ubuntu

# -- Healthcheck: verify binaries are functional ------------------------------
HEALTHCHECK --interval=60s --timeout=5s --retries=1 \
    CMD DensifyPointCloud --help > /dev/null 2>&1 || exit 1

# -- Default entrypoint -------------------------------------------------------
ENTRYPOINT ["/bin/bash"]
