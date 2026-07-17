#!/usr/bin/env bash
set -euo pipefail

echo "==> Unlocking pacman speed and aesthetics..."
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

echo "==> Setting up CI Reflector for fast build speeds..."
pacman -Sy --noconfirm reflector
reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

echo "==> Injecting CachyOS Repositories (x86-64-v3)..."
cd /tmp
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo
# The script automatically detects your v3 architecture and modifies pacman.conf
./cachyos-repo.sh

echo "==> Swapping Arch kernel for CachyOS BORE..."
# Force a full sync so pacman registers the new CachyOS databases
pacman -Syu --noconfirm

# Install the BORE kernel, headers, and the recommended NVIDIA DKMS driver for your RTX 3050
pacman -S --noconfirm linux-cachyos-bore linux-cachyos-bore-headers nvidia-open-dkms nvidia-utils

# Nuke the stock kernel from orbit so bootc and DKMS don't get confused
echo "==> Purging stock Linux kernel..."
pacman -Rns --noconfirm linux linux-headers || true

echo "==> CachyOS Preset applied successfully."
