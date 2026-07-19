#!/usr/bin/env bash
set -euo pipefail

echo "==> Preparing builder environment for HEAVY AUR packages..."

if [ ! -d "/var/home/builder" ]; then
    echo "==> /var/home/builder missing. Recreating due to OCI VOLUME purge..."
    mkdir -p /var/home/builder
    chown builder:builder /var/home/builder
fi

if [ -L "/opt" ]; then
    echo "==> Removing /opt symlink to allow proprietary AUR installations..."
    rm -f /opt
    mkdir -p /opt
fi

echo "==> Installing HEAVY AUR packages from source..."

sudo -u builder bash -c '
    packages=(
        msi-ec-dkms-git
        noctalia-git
        noctalia-greeter-git
    )
    yes "" | yay -S --noconfirm --needed "${packages[@]}"
'

echo "==> Relocating /opt to /usr/lib/opt for OSTree persistence..."
mkdir -p /usr/lib/opt

echo "==> Heavy AUR packages installed."
