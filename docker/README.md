# Building & Running OpenMVS with Docker

## Quick Start

Pull the pre-built image and run interactively:

```bash
./QUICK_START.sh /path/to/your/sfm/data
```

This mounts your data at `/data` inside the container. All OpenMVS binaries
(`DensifyPointCloud`, `ReconstructMesh`, `RefineMesh`, `TextureMesh`) are on `$PATH`.

## Build from Source

Build the Docker image from this repository's source code:

```bash
# CPU-only build
./buildFromScratch.sh --workspace /path/to/data

# With CUDA support (requires NVIDIA Container Toolkit)
./buildFromScratch.sh --cuda --workspace /path/to/data
```

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `BASE_IMAGE` | `ubuntu:24.04` | Builder stage base image |
| `RUNTIME_IMAGE` | `ubuntu:24.04` | Runtime stage base image |
| `CUDA` | `0` | Set to `1` to enable CUDA support |
| `OPENMVS_BRANCH` | `develop` | Git branch to build from (`develop` or `master`) |

### CUDA Build

For CUDA support, use NVIDIA base images:

```bash
docker build \
    --build-arg CUDA=1 \
    --build-arg BASE_IMAGE=nvidia/cuda:12.9.1-devel-ubuntu24.04 \
    --build-arg RUNTIME_IMAGE=nvidia/cuda:12.9.1-runtime-ubuntu24.04 \
    -f docker/Dockerfile \
    -t openmvs-cuda .
```

CUDA architectures compiled: `75, 80, 86, 89, 90` (Turing, Ampere, Ada Lovelace, Hopper).

## Image Architecture

Multi-stage build for minimal image size:

1. **Builder stage**: Compiles Eigen 3.4, CGAL 6.0.1, VCGlib, and OpenMVS from source
2. **Runtime stage**: Copies only binaries and runtime libraries — no compilers or headers

The runtime image includes:
- OpenMVS binaries in `/usr/local/bin/OpenMVS/`
- Python 3.12 with venv at `/opt/venv` (PEP 668 compliant)
- Non-root user `openmvs` (UID/GID 1000)
- Working directory `/data`

## Example Workflow

```bash
# Inside the container
cd /data

# Convert COLMAP output to OpenMVS format
InterfaceCOLMAP -i /data/colmap_output -o scene.mvs

# Densify point cloud
DensifyPointCloud scene.mvs

# Reconstruct mesh
ReconstructMesh scene_dense.mvs

# Refine mesh
RefineMesh scene_dense_mesh.mvs --resolution-level 1

# Texture mesh
TextureMesh scene_dense_mesh_refine.mvs
```

## GitHub Actions

The Docker image is automatically built and pushed to `ghcr.io` on every push
to `develop` or `master`. See `.github/workflows/docker-build.yml`.

## Software Bill of Materials

See [SBOM.md](SBOM.md) for the complete dependency list with versions and sources.

## Notes

- OpenMVS can use significant memory. Increase Docker's memory limit for larger datasets.
- X11 display forwarding is supported via `buildFromScratch.sh` for the Viewer.
- The image runs as non-root user `openmvs` by default.
