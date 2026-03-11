# Software Bill of Materials (SBOM)

## OpenMVS Docker Image

**Image**: `ghcr.io/shadnygren/openmvs`
**Base OS**: Ubuntu 24.04 LTS (Noble Numbat)
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
| CGAL | 6.0.1 | https://github.com/CGAL/cgal (tag v6.0.1) | LGPL-3.0 / GPL-3.0 |
| VCGlib | HEAD | https://github.com/cdcseacave/VCG | GPL-3.0 |

## System Packages (Ubuntu 24.04 APT)

### Build Stage Only (not in runtime image)

| Package | Purpose |
|---------|---------|
| build-essential | GCC, G++, make |
| cmake | Build system |
| git | Source checkout |
| *-dev packages | Headers for compilation |

### Runtime Stage

| Package | Version (Ubuntu 24.04) | Purpose | License |
|---------|----------------------|---------|---------|
| libboost-iostreams1.83.0 | 1.83.0 | I/O streaming | BSL-1.0 |
| libboost-program-options1.83.0 | 1.83.0 | CLI argument parsing | BSL-1.0 |
| libboost-serialization1.83.0 | 1.83.0 | Object serialization | BSL-1.0 |
| libboost-system1.83.0 | 1.83.0 | System utilities | BSL-1.0 |
| libopencv-core406t64 | 4.6.0 | Core computer vision | Apache-2.0 |
| libopencv-imgcodecs406t64 | 4.6.0 | Image I/O | Apache-2.0 |
| libopencv-imgproc406t64 | 4.6.0 | Image processing | Apache-2.0 |
| libopencv-features2d406t64 | 4.6.0 | Feature detection | Apache-2.0 |
| libopencv-calib3d406t64 | 4.6.0 | Camera calibration | Apache-2.0 |
| libopencv-highgui406t64 | 4.6.0 | GUI/display | Apache-2.0 |
| libgmp10 | 6.3.0 | Arbitrary precision math | LGPL-3.0 |
| libmpfr6 | 4.2.1 | Multi-precision floats | LGPL-3.0 |
| libgomp1 | 14.x | OpenMP runtime | GPL-3.0 (runtime exception) |
| libglu1-mesa | 9.0.2 | OpenGL utilities | SGI-B-2.0 |
| libglew2.2 | 2.2.0 | OpenGL extension wrangler | BSD-3-Clause |
| libglfw3 | 3.3.8 | Window/input management | Zlib |
| libpng16-16t64 | 1.6.43 | PNG image I/O | Libpng |
| libjpeg-turbo8 | 2.1.5 | JPEG image I/O | IJG / BSD-3-Clause |
| libtiff6 | 4.5.1 | TIFF image I/O | libtiff |
| libjxl0.9 | 0.9.x | JPEG XL image I/O | BSD-3-Clause |
| python3 | 3.12.x | Python runtime | PSF-2.0 |
| python3-venv | 3.12.x | Virtual environments | PSF-2.0 |

## CUDA Variant (optional)

When built with `--build-arg CUDA=1`:

| Component | Version | Source | License |
|-----------|---------|--------|---------|
| NVIDIA CUDA Toolkit | 12.9.1 | nvidia/cuda Docker images | NVIDIA EULA |
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
1. **Ubuntu 24.04 APT repositories** — Canonical's official package archive
2. **Official Git repositories** — tagged releases from upstream maintainers
3. **NVIDIA Container Images** — official CUDA base images from Docker Hub
