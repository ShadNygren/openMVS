# Ubuntu 26.04 LTS "Resolute Raccoon" — Changes from 24.04 and 22.04

> **Release date**: April 23, 2026
> **Support**: 5 years (until April 2031)
> **Codename**: Resolute Raccoon
> **Docker image**: `ubuntu:26.04`

This document covers breaking changes, package version differences, and migration
notes relevant to Docker container builds and C++ development workloads.

---

## Package Version Comparison

| Package | Ubuntu 22.04 | Ubuntu 24.04 | Ubuntu 26.04 | Notes |
|---------|-------------|-------------|-------------|-------|
| **Python** | 3.10.x | 3.12.x | **3.14.2** | No-GIL experimental support |
| **GCC** | 11 | 13 | **15** (GCC 16 optional) | |
| **CMake** | 3.22 | 3.28 | **4.2.3** | Major version bump! |
| **Boost** | 1.74.0 | 1.83.0 | **1.90.0** | Runtime lib suffix changed |
| **OpenCV** | 4.5.4 | 4.6.0 | **4.10.0** | JPEGXL support included |
| **Eigen** | 3.4.0 | 3.4.0 | **3.4.0** | Unchanged |
| **CGAL** | 5.4 | 5.6 | **6.1.1** | Major version bump |
| **nanoflann** | N/A | 1.5.4 | **1.9.0** | |
| **libjxl** | N/A | 0.7.0 | **0.11.1** | Major version bump |
| **glibc** | 2.35 | 2.39 | **2.42** | |
| **OpenSSL** | 3.0 | 3.0 | **3.5.3** | Major version bump |
| **Kernel** | 5.15 | 6.8 | **7.0** | |
| **LLVM** | 14 | 18 | **21** | |
| **Rust** | N/A | 1.75 | **1.93.1** | System language |
| **Docker** | 24.x | 27.x | **29.x** | containerd 2.2.1 |
| **systemd** | 249 | 255 | **257.4** | |
| **APT** | 2.4 | 2.7 | **3.0** | Major version bump |

### Runtime Library Name Changes (for Dockerfiles)

| Library | Ubuntu 24.04 | Ubuntu 26.04 |
|---------|-------------|-------------|
| Boost iostreams | `libboost-iostreams1.83.0` | `libboost-iostreams1.90.0` |
| Boost program-options | `libboost-program-options1.83.0` | `libboost-program-options1.90.0` |
| Boost serialization | `libboost-serialization1.83.0` | `libboost-serialization1.90.0` |
| Boost system | `libboost-system1.83.0` | `libboost-system1.90.0` |
| libjxl | `libjxl0.7` | `libjxl0.11` |
| OpenCV | `libopencv-core406t64` | **Use `libopencv-dev` (4.10.0)** |
| libpng | `libpng16-16t64` | `libpng16-16t64` (unchanged) |
| libjpeg | `libjpeg-turbo8` | `libjpeg-turbo8` (unchanged) |
| libtiff | `libtiff6` | `libtiff6` (unchanged) |
| libglew | `libglew2.2` | `libglew2.2` (unchanged) |

---

## Breaking Changes Affecting Docker/Development

### 1. Python 3.14 (was 3.12)

- **No-GIL experimental**: Python 3.14 introduces major steps toward removing the
  Global Interpreter Lock for true parallelism. This is opt-in via build flag.
- **PEP 668 still enforced**: Must use `python3 -m venv` for pip installs. Same as 24.04.
- **New deprecations**: Various stdlib modules marked for removal.
- **`python3-dev` package**: Now `3.14.2-1`.

### 2. CMake 4.x (was 3.28)

- Major version bump from 3.x to 4.x.
- CMake 4.0 released January 2026 with policy changes.
- `CMAKE_MINIMUM_REQUIRED(VERSION 3.18)` still works (backwards compatible).
- Some deprecated commands may now error instead of warn.

### 3. GCC 15 (was 13)

- Default compiler is now GCC 15.
- Stricter warnings and potential new errors for previously-warning code.
- C++23 support improved.
- GCC 16 available as optional toolchain.

### 4. Boost 1.90 (was 1.83)

- Runtime library suffix changed: `1.83.0` → `1.90.0`.
- Dockerfiles that pin specific Boost runtime versions must update.
- The `-dev` packages (used at build time) are version-agnostic: `libboost-*-dev`.

### 5. OpenCV 4.10 (was 4.6)

- **This is the key fix**: `cv::IMWRITE_JPEGXL_QUALITY` now available natively.
- No need to compile OpenCV from source on 26.04.
- Simply `apt-get install libopencv-dev` provides 4.10.0.

### 6. CGAL 6.1 (was 5.6)

- Major version bump from 5.x to 6.x.
- API changes in some CGAL modules. OpenMVS uses a subset that is stable.

### 7. OpenSSL 3.5 (was 3.0)

- Major version bump.
- Post-quantum cryptography defaults.
- DSA signature algorithm removed from OpenSSH.

### 8. Rust-based Core Utilities (NEW)

- `ls`, `cp`, `mv`, `sort`, `cksum` etc. replaced by Rust `uutils` implementations.
- **Known issues**: `cksum` up to 17x slower for some large files. `sort` may fail on
  very large single-line files.
- For Docker containers: minimal impact since most builds use `apt-get` and `cmake`,
  not coreutils-heavy workflows. But scripts using obscure GNU coreutils flags should
  be tested.

### 9. Docker Engine 29 / containerd 2.2.1

- Containerd image store now default for fresh installs.
- `runc` 1.4.0: `pids.limit` handling updated to match OCI spec (value of 0 = actual limit).
- nftables firewall backend (experimental).

### 10. Wayland-only GNOME 50

- X11 removed from GNOME session. Does not affect headless Docker containers.
- Other DEs (KDE, XFCE) retain X11 support.

---

## Migration Checklist for Docker Builds

### From Ubuntu 24.04 → 26.04

- [ ] Update `FROM ubuntu:24.04` → `FROM ubuntu:26.04`
- [ ] Remove OpenCV source compilation (now available as `libopencv-dev` 4.10.0)
- [ ] Update Boost runtime library names: `1.83.0` → `1.90.0`
- [ ] Update `libjxl` runtime: `libjxl0.7` → `libjxl0.11`
- [ ] Test CMake 4.x compatibility (should be backwards-compatible)
- [ ] Test GCC 15 compilation (stricter warnings)
- [ ] Python venv path unchanged (`python3 -m venv` still required)
- [ ] Verify Rust coreutils don't break any build scripts

### From Ubuntu 22.04 → 26.04

All of the above, plus:
- [ ] PEP 668: Must use Python venv (no bare `pip install`)
- [ ] `t64` package name suffix on some libraries (64-bit time_t transition from 24.04)
- [ ] CMake version jump from 3.22 → 4.2 (two major versions)
- [ ] Boost version jump from 1.74 → 1.90
- [ ] OpenSSL jump from 3.0 → 3.5

---

## Known Issues (as of March 2026, pre-release)

1. **TPM FDE installs fail to boot** post-installation (LP: #2104316)
2. **Rust coreutils performance**: `cksum` significantly slower, `sort` edge cases
3. **NVIDIA Wayland**: Visual corruption on suspend/resume
4. **Network interface boot hang**: Unconfigured interfaces assume DHCP4, can block boot

These primarily affect desktop/server installs, not Docker containers.

---

## Impact on OpenMVS Docker Build

**Positive changes (simplifications)**:
- OpenCV 4.10 via `apt-get` — no source compilation needed (~10 min saved)
- libjxl 0.11 via `apt-get` — latest version, full JPEGXL support
- CGAL 6.1 via `apt-get` — could replace source compilation of CGAL 6.0.1
- nanoflann 1.9 via `apt-get` — already packaged

**Requires attention**:
- Boost runtime lib names changed (update Dockerfile)
- GCC 15 may produce new warnings (test compilation)
- CMake 4.x (should be fine, OpenMVS requires 3.18+)

---

## Sources

- [Resolute Raccoon Release Notes](https://discourse.ubuntu.com/t/resolute-raccoon-release-notes/59221)
- [Ubuntu 26.04 vs 24.04 LTS: Why Resolute Raccoon Is a Real Architectural Break](https://www.pudn.club/linux/ubuntu-26.04-vs-24.04-lts-why-resolute-raccoon-is-a-real-architectural-break/)
- [Ubuntu 26.04: Release Date and New Features](https://linuxconfig.org/ubuntu-26-04-release-date-and-new-features-in-resolute-raccoon)
- [Ubuntu 26.04 LTS: Release Date and New Features (It's FOSS)](https://itsfoss.com/ubuntu-26-04-release-features/)
- [Ubuntu 26.04 Snapshot 4 Released (Phoronix)](https://www.phoronix.com/news/Ubuntu-26.04-Snapshot-4)
- [Rust Coreutils Performance Issues](https://itsfoss.com/news/ubuntu-uutils-performance-issues/)
- [PEP 668 – Externally Managed Environments](https://peps.python.org/pep-0668/)
