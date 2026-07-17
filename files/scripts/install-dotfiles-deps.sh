echo "==> Preparing builder environment for personal packages..."

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

# 2. The Headless Meta-Package Builder
sudo -u builder bash -c '
    cd ~/dots-hyprland/sdata/dist-arch
    
    # The exact list of meta-packages from End-4s install-deps.sh
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
        
        # Source the PKGBUILD to get his specific depends array
        source ./PKGBUILD
        
        # Install dependencies natively if they exist (prevents yay from crashing on empty arrays)
        if [ ${#depends[@]} -gt 0 ]; then
            yay -S --noconfirm --asdeps "${depends[@]}"
        fi
        
        # Build and install the meta-package itself
        makepkg -Afsi --noconfirm
        
        cd ..
    done
    
    # Force install the optional plasma integration without the [y/N] prompt
    yay -S --noconfirm plasma-browser-integration
'
