#!/usr/bin/env bash
set -euo pipefail

echo "==> Unlocking pacman speed and aesthetics..."
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

# Disable Pacman 7.0+ sandboxing because it breaks inside OCI containers
if grep -q "^#DisableSandbox" /etc/pacman.conf; then
    sed -i 's/^#DisableSandbox/DisableSandbox/' /etc/pacman.conf
else
    # If it's not there, forcefully inject it under [options]
    sed -i '/^\[options\]/a DisableSandbox' /etc/pacman.conf
fi

echo "==> Setting up CI Reflector for fast build speeds..."
pacman -Sy --noconfirm reflector
# Make reflector fail-safe just in case GitHub Actions networking acts up
reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist --connection-timeout 15 --download-timeout 15 || echo "Reflector failed, falling back..."

echo "==> Initializing pacman keyring for third-party signatures..."
# Generate the local machine secret key so we can sign the CachyOS keys
pacman-key --init
pacman-key --populate archlinux

echo "==> Injecting CachyOS Repositories (x86-64-v3)..."
cd /tmp
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo
# The script automatically detects your v3 architecture and modifies pacman.conf
yes "" | ./cachyos-repo.sh
