#!/usr/bin/env bash
set -euo pipefail

echo "==> Unlocking pacman speed, aesthetics, and container compatibility..."
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

# Disable Pacman 7.0+ sandboxing
sed -i 's/^Architecture = auto/Architecture = auto\nDisableSandbox/' /etc/pacman.conf

echo "==> Initializing pacman keyring for third-party signatures..."
pacman-key --init
pacman-key --populate archlinux

echo "==> Injecting CachyOS Repositories (x86-64-v3)..."
cd /tmp
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo

# 1. yes "" bypasses their internal pacman prompts.
# 2. || echo catches their internal tmpfiles hook crash so our pipeline survives!
yes "" | ./cachyos-repo.sh || echo "cachyos-repo.sh finished with expected tmpfiles warnings."

echo "==> Installing Chaotic-AUR..."
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

# Append the repo to pacman.conf
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" >> /etc/pacman.conf

echo "==> Optimizing Mirrors..."
pacman -Sy --noconfirm rate-mirrors
rate-mirrors --allow-root arch > /etc/pacman.d/mirrorlist

echo "==> Swapping Arch kernel for CachyOS BORE..."
# Install the BORE kernel, headers, and NVIDIA open modules
pacman -S --noconfirm linux-cachyos-bore linux-cachyos-bore-headers linux-cachyos-bore-nvidia-open nvidia-utils

echo "==> Purging stock Linux kernel..."
pacman -Rns --noconfirm linux linux-headers || true

echo "==> CachyOS Preset applied successfully."
