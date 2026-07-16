#!/usr/bin/env bash
set -euo pipefail

echo "Building mpvpaper from source..."

# 1. Install all mapped build dependencies (including the hidden ones Claude found)
dnf install -y --allowerasing mpv-libs-devel wayland-devel meson ninja-build wayland-protocols-devel mesa-libEGL-devel pkgconf-pkg-config gcc

# 2. Clone the repository (using git instead of the tarball for cleaner extraction)
git clone https://github.com/GhostNaN/mpvpaper.git /tmp/mpvpaper
cd /tmp/mpvpaper

# 3. Build (Replacing the fake 'arch-meson' with the standard meson equivalent)
meson setup build --prefix=/usr --buildtype=release
meson compile -C build

# 4. Install directly to the container's root filesystem (no $pkgdir needed here)
meson install -C build

# 5. Install the man page exactly as the PKGBUILD requested
install -vDm644 mpvpaper.man /usr/share/man/man1/mpvpaper.1

# 6. Aggressive Cleanup (Nuke the compilers so the image stays small!)
rm -rf /tmp/mpvpaper
dnf remove -y wayland-devel meson ninja-build wayland-protocols-devel mesa-libEGL-devel gcc
dnf clean all
