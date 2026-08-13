#!/usr/bin/env bash
set -euo pipefail

echo "==> Preparing builder environment for personal packages..."

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

echo "==> Installing personal packages..."

sudo -u builder bash -c '
    packages=(
        # === Desktop & WM ===
        hyprland greetd accountsservice
        cliphist wl-clipboard hyprsunset nwg-displays
        xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-user-dirs xdg-utils
        qt6ct-kde qt6-wayland polkit switcheroo-control
        adw-gtk-theme papirus-icon-theme

        # === Browsers ===
        zen-browser-bin thorium-browser-avx2-bin

        # === Audio Stack ===
        pipewire pipewire-pulse pipewire-alsa wireplumber
        alsa-utils sof-firmware pavucontrol easyeffects lsp-plugins
        mpd mpd-mpris rmpc mpv mpv-mpris ffmpeg ffmpegthumbnailer
        spicetify-cli cava

        # === Fonts ===
        apple-fonts inter-font ttf-roboto ttf-twemoji
        noto-fonts noto-fonts-cjk noto-fonts-emoji
        ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common

        # === Shell & Terminal ===
        fish fisher atuin zoxide starship kitty

        # === CLI Tools (AI + Personal) ===
        sd ast-grep dust procs jc go-yq htmlq ripgrep-all yt-dlp
        jq tealdeer trash-cli ouch trippy httpie
        bc rsync wget curl openbsd-netcat
        p7zip unrar zip

        # === Dev Tools ===
        github-cli uv mold python python-rich python-tomli-w
        libxcrypt-compat

        # === System Utils ===
        btop inxi lshw lm_sensors iputils bind-utils iproute smartmontools
        btrfs-progs compsize btrfsmaintenance fuse-overlayfs fuse2
        zram-generator keyd evtest opentabletdriver xorg-xhost udiskie
        gnome-keyring libnotify upower power-profiles-daemon

        # === Networking ===
        networkmanager iwd bluez bluez-utils blueman
        wireguard-tools tailscale samba dnsmasq
        bridge-utils vde2

        # === GPU Drivers ===
        nvidia-utils nvidia-prime lib32-nvidia-utils
        vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
        intel-media-driver intel-ucode
        mesa lib32-mesa mangohud lib32-mangohud

        # === Kernel & Power ===
        msi-ec-dkms-git scx-scheds scx-tools cachyos-settings
        nohang fwupd bpftune thermald

        # === Virtualization ===
        qemu-full libvirt virt-manager virt-viewer edk2-ovmf swtpm iptables-nft

        # === Gaming ===
        steam moonlight-qt mgba-qt emulationstation-de

        # === Personal Apps ===
        mcontrolcenter celluloid vesktop obsidian foliate
        aria2 freedownloadmanager gdu imv
        opencode astralrinth-bin h-m-m-git
    )
    
    if [ ${#packages[@]} -gt 0 ]; then
        yes "" | yay -S --noconfirm --needed "${packages[@]}"
    else
        echo "No personal packages defined. Skipping."
    fi
'

echo "==> Relocating /opt to /usr/lib/opt for OSTree persistence..."
mkdir -p /usr/lib/opt

if [ "$(ls -A /opt)" ]; then
    cp -a /opt/. /usr/lib/opt/
fi

rm -rf /opt
mkdir -p /opt

echo "==> Personal packages installed."

echo "==> Removing obsolete packages from the base image..."
obsolete=()
for package in nodejs npm go obs-studio rpm-tools; do
    pacman -Qq "$package" &>/dev/null && obsolete+=("$package")
done

if [ ${#obsolete[@]} -gt 0 ]; then
    pacman -Rns --noconfirm "${obsolete[@]}"
fi
