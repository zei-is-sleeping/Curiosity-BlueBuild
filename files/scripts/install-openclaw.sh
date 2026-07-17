#!/usr/bin/env bash
set -euo pipefail

echo "==> Building OpenClaw from source via npm..."

# Install build and runtime dependencies
# (gcc and make are already provided by base-devel from Step 1)
pacman -S --needed --noconfirm nodejs npm cmake python

# Install openclaw globally into the immutable /usr
echo "==> Running npm install..."
HOME=/tmp npm install -g --prefix=/usr openclaw@latest

# Clean up build-only dependencies to save image space
# We leave nodejs because OpenClaw needs it to run!
echo "==> Removing npm and build-time dependencies..."
pacman -Rns --noconfirm npm cmake || true

echo "==> OpenClaw installed successfully."
