#!/usr/bin/env bash
set -euo pipefail

echo "==> Preparing builder environment for dotfiles..."

# Recreate the builder's home directory if the OCI runtime wiped it between layers
if [ ! -d "/var/home/builder" ]; then
    echo "==> /var/home/builder missing. Recreating due to OCI VOLUME purge..."
    mkdir -p /var/home/builder
    chown builder:builder /var/home/builder
fi
