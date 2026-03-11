# Software Bill of Materials (SBOM)

## OpenMVS Docker Image

**Image**: `ghcr.io/shadnygren/openmvs`
**Base OS**: Ubuntu 26.04 LTS (Resolute Raccoon)
**Architecture**: x86_64 (amd64)
**Build date**: See image labels

---

## Core Application

| Component | Version | Source | License |
|-----------|---------|--------|---------|
| OpenMVS | 2.4.0 (develop) | https://github.com/cdcseacave/openMVS | AGPL-3.0 |

## Compiled from Source

| Component | Version | Source | License |
|-----------|---------|--------|---------|
| Eigen | 3.4.x | https://gitlab.com/libeigen/eigen (branch 3.4) | MPL-2.0 |
| OpenCV | 4.10.0 | https://github.com/opencv/opencv (tag 4.10.0) | Apache-2.0 |
| VCGlib | HEAD | https://github.com/cdcseacave/VCG | GPL-3.0 |

## System Packages (Ubuntu 26.04 APT)

### Build Stage Only (not in runtime image)

| Package | Purpose |
|---------|---------|
| build-essential | GCC 15, G++, make |
| cmake | Build system (4.2.x) |
| git | Source checkout |
| libopencv-dev | OpenCV 4.10.0 headers and libs |
| libcgal-dev | CGAL 6.1.1 headers |
| *-dev packages | Headers for compilation |

### Runtime Stage

| Package | Version (Ubuntu 26.04) | Purpose | License |
|---------|----------------------|---------|---------|
| libboost-iostreams1.90.0 | 1.90.0 | I/O streaming | BSL-1.0 |
| libboost-program-options1.90.0 | 1.90.0 | CLI argument parsing | BSL-1.0 |
| libboost-serialization1.90.0 | 1.90.0 | Object serialization | BSL-1.0 |
| libboost-system1.90.0 | 1.90.0 | System utilities | BSL-1.0 |
| OpenCV 4.10.0 (from source) | 4.10.0 | Compiled with JPEGXL support | Apache-2.0 |
| libgmp10 | 6.3.0 | Arbitrary precision math | LGPL-3.0 |
| libmpfr6 | 4.2.1 | Multi-precision floats | LGPL-3.0 |
| libgomp1 | 15.x | OpenMP runtime | GPL-3.0 (runtime exception) |
| libglu1-mesa | 9.0.2 | OpenGL utilities | SGI-B-2.0 |
| libglew2.2 | 2.2.0 | OpenGL extension wrangler | BSD-3-Clause |
| libglfw3 | 3.3.x | Window/input management | Zlib |
| libpng16-16t64 | 1.6.x | PNG image I/O | Libpng |
| libjpeg-turbo8 | 2.x | JPEG image I/O | IJG / BSD-3-Clause |
| libtiff6 | 4.x | TIFF image I/O | libtiff |
| libjxl0.11 | 0.11.x | JPEG XL image I/O | BSD-3-Clause |
| python3 | 3.14.x | Python runtime | PSF-2.0 |
| python3-venv | 3.14.x | Virtual environments | PSF-2.0 |

## CUDA Variant (optional — currently disabled)

CUDA variant is temporarily disabled pending nvidia/cuda Docker images for
Ubuntu 26.04 (expected shortly after Ubuntu 26.04 GA on April 23, 2026).

When available, build with:
```
docker build --build-arg CUDA=1 \
  --build-arg BASE_IMAGE=nvidia/cuda:XX.X-devel-ubuntu26.04 \
  --build-arg RUNTIME_IMAGE=nvidia/cuda:XX.X-runtime-ubuntu26.04 \
  -t openmvs-cuda .
```

| Component | Version | Source | License |
|-----------|---------|--------|---------|
| NVIDIA CUDA Toolkit | TBD | nvidia/cuda Docker images | NVIDIA EULA |
| Target architectures | 75, 80, 86, 89, 90 | Turing, Ampere, Ada, Hopper | — |

## Container Metadata

| Label | Value |
|-------|-------|
| `org.opencontainers.image.source` | https://github.com/ShadNygren/openMVS |
| `org.opencontainers.image.licenses` | AGPL-3.0 |
| `org.opencontainers.image.vendor` | ShadNygren |
| Python venv | `/opt/venv` |
| Non-root user | `openmvs` (UID 1000) |
| Binaries path | `/usr/local/bin/OpenMVS/` |

## Authoritative Sources

All packages come from one of these authoritative sources:
1. **Ubuntu 26.04 APT repositories** — Canonical's official package archive
2. **Official Git repositories** — tagged releases from upstream maintainers
3. **NVIDIA Container Images** — official CUDA base images from Docker Hub (when available)
