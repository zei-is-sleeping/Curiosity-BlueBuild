#!/usr/bin/env bash
set -euo pipefail

echo "==> Preparing builder environment for dotfiles..."

# Recreate the builder's home directory if the OCI runtime wiped it between layers
if [ ! -d "/var/home/builder" ]; then
    echo "==> /var/home/builder missing. Recreating due to OCI VOLUME purge..."
    mkdir -p /var/home/builder
    chown builder:builder /var/home/builder
fi

echo "==> Installing dotfile deps..."

sudo -u builder bash -c '
    cd ~
    git clone --depth=1 https://github.com/end-4/dots-hyprland.git
'

# The Headless Meta-Package Builder
sudo -u builder bash -c '
    cd ~/dots-hyprland/sdata/dist-arch
    
    metapkgs=(
        illogical-impulse-audio
        illogical-impulse-backlight
        illogical-impulse-basic
        illogical-impulse-fonts-themes
        illogical-impulse-kde
        illogical-impulse-portal
        illogical-impulse-python
        illogical-impulse-screencapture
        illogical-impulse-toolkit
        illogical-impulse-widgets
        illogical-impulse-hyprland
        illogical-impulse-microtex-git
        illogical-impulse-quickshell-git
        illogical-impulse-bibata-modern-classic-bin
    )
    
    for pkg in "${metapkgs[@]}"; do
        echo "==> Building $pkg"
        cd "$pkg"
        
        # Unset arrays to prevent bleeding between loop iterations
        unset depends makedepends
        
        source ./PKGBUILD
        
        # Safely combine depends and makedepends if they exist
        deps_to_install=()
        if [ ${#depends[@]} -gt 0 ]; then deps_to_install+=("${depends[@]}"); fi
        if [ ${#makedepends[@]} -gt 0 ]; then deps_to_install+=("${makedepends[@]}"); fi
        
        # Install dependencies via yay (yes pipe bypasses provider prompts)
        if [ ${#deps_to_install[@]} -gt 0 ]; then
            yes "" | yay -S --noconfirm --asdeps "${deps_to_install[@]}"
        fi
        
        # Build and install the meta-package
        yes "" | makepkg -Afsi --noconfirm
        
        cd ..
    done
    
    yes "" | yay -S --noconfirm plasma-browser-integration
'
