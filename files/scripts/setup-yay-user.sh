#!/usr/bin/env bash
set -euo pipefail

echo "==> Optimizing makepkg.conf for Lightning Builds..."
# Strip out debug and lto to save massive amounts of time
sed -i 's/OPTIONS=(strip docs \!libtool \!staticlibs emptydirs zipman purge \!debug lto)/OPTIONS=(strip docs \!libtool \!staticlibs emptydirs zipman purge \!debug \!lto)/' /etc/makepkg.conf

# Force makepkg to use the blazingly fast 'mold' linker
sed -i 's/^#LDFLAGS.*/LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,-mllvm -Wl,-instcombine-lower-dbg-declare=0 -fuse-ld=mold"/' /etc/makepkg.conf
sed -i 's/^#RUSTFLAGS.*/RUSTFLAGS="-C opt-level=2 -C target-cpu=native -C link-arg=-fuse-ld=mold"/' /etc/makepkg.conf
sed -i 's/^#MAKEFLAGS="-j2".*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

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
