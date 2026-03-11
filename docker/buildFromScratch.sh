#!/bin/bash
# =============================================================================
# Build OpenMVS Docker image from source (CPU or CUDA)
# Copyright (c) 2026 Shad Nygren, Virtual Hipster Corporation
# Licensed under AGPL-3.0 (same as OpenMVS)
# =============================================================================
#
# Usage:
#   ./buildFromScratch.sh --workspace /path/to/data
#   ./buildFromScratch.sh --cuda --workspace /path/to/data
#   ./buildFromScratch.sh --cuda --master --workspace /path/to/data
#
# =============================================================================

set -euo pipefail

WORKSPACE="$(pwd)"
CUDA_BUILD_ARGS=""
CUDA_RUNTIME_ARGS=""
CUDA_CONTAINER_SUFFIX=""
BRANCH_ARG=""
IMAGE_TAG="openmvs-ubuntu"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --cuda)
            CUDA_BUILD_ARGS="--build-arg CUDA=1 --build-arg BASE_IMAGE=nvidia/cuda:12.9.1-devel-ubuntu24.04 --build-arg RUNTIME_IMAGE=nvidia/cuda:12.9.1-runtime-ubuntu24.04"
            CUDA_RUNTIME_ARGS="--gpus all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics"
            CUDA_CONTAINER_SUFFIX="-cuda"
            shift
            ;;
        --master)
            BRANCH_ARG="--build-arg OPENMVS_BRANCH=master"
            shift
            ;;
        --workspace)
            WORKSPACE="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--cuda] [--master] [--workspace /path/to/data]"
            exit 1
            ;;
    esac
done

IMAGE_TAG="${IMAGE_TAG}${CUDA_CONTAINER_SUFFIX}"

echo "============================================="
echo "  OpenMVS Docker Build"
echo "  Image:     ${IMAGE_TAG}"
echo "  CUDA:      $([ -n "$CUDA_CONTAINER_SUFFIX" ] && echo 'YES' || echo 'NO')"
echo "  Workspace: ${WORKSPACE}"
echo "============================================="

# Build from the repo root (one level up from docker/) so COPY . gets the source
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

docker build \
    -f "${REPO_ROOT}/docker/Dockerfile" \
    -t "${IMAGE_TAG}" \
    ${CUDA_BUILD_ARGS} \
    ${BRANCH_ARG} \
    "${REPO_ROOT}"

echo ""
echo "Build complete: ${IMAGE_TAG}"
echo "Starting container with workspace: ${WORKSPACE}"
echo ""

# X11 forwarding for Viewer (optional, fails gracefully)
DISPLAY_ARGS=""
if [ -n "${DISPLAY:-}" ]; then
    XSOCK=/tmp/.X11-unix
    XAUTH=/tmp/.docker.xauth
    touch "$XAUTH"
    xauth nlist "$DISPLAY" 2>/dev/null | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge - 2>/dev/null || true
    DISPLAY_ARGS="--volume=${XSOCK}:${XSOCK}:rw --volume=${XAUTH}:${XAUTH}:rw --env=XAUTHORITY=${XAUTH} --env=DISPLAY=unix${DISPLAY}"
fi

docker run \
    ${CUDA_RUNTIME_ARGS} \
    --ipc=host \
    --shm-size=4gb \
    -w /data \
    -v "${WORKSPACE}:/data" \
    ${DISPLAY_ARGS} \
    -it "${IMAGE_TAG}"
