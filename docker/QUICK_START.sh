#!/bin/bash
# =============================================================================
# Quick Start — pull pre-built OpenMVS image and run interactively
# Copyright (c) 2026 Shad Nygren, Virtual Hipster Corporation
# Licensed under AGPL-3.0 (same as OpenMVS)
# =============================================================================
#
# Usage:
#   ./QUICK_START.sh /path/to/your/sfm/data
#
# =============================================================================

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 /path/to/your/sfm/data"
    echo ""
    echo "Pulls the latest OpenMVS Docker image and opens an interactive shell"
    echo "with your data directory mounted at /data."
    exit 1
fi

IMAGE="ghcr.io/shadnygren/openmvs:latest"

echo "Pulling ${IMAGE}..."
docker pull "${IMAGE}"

echo "Starting container with workspace: $1"
docker run \
    --ipc=host \
    --shm-size=4gb \
    -w /data \
    -v "$1:/data" \
    -it "${IMAGE}"
