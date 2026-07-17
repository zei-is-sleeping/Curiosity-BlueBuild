#!/usr/bin/env bash
set -euo pipefail

echo "==> Creating builder user for AUR..."
# Create user with a home directory (which will map to /var/home/builder)
useradd -m -G wheel builder

# Safely give builder passwordless sudo without touching the main sudoers file
echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder-nopasswd
chmod 0440 /etc/sudoers.d/builder-nopasswd

echo "==> Cloning and installing yay-bin..."
sudo -u builder bash -c '
    cd ~
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    makepkg -si --noconfirm
'

echo "==> yay installed successfully."
