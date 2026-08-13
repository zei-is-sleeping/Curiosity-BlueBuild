#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/curiosity-build/timing.sh
timing_start_script install-personal

echo "==> Preparing builder environment for personal packages..."

prepare_package_environment() {
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
}
time_step "packages: prepare builder home and /opt" prepare_package_environment

echo "==> Installing personal packages..."

packages=(
        # === Desktop & WM ===
        hyprland greetd accountsservice
        cliphist wl-clipboard hyprsunset nwg-displays
        xdg-desktop-portal-gtk xdg-desktop-portal-hyprland xdg-user-dirs xdg-utils
        qt6ct-kde qt6-wayland polkit switcheroo-control
        adw-gtk-theme papirus-icon-theme
        cachyos-extra-v3/noctalia cachyos/noctalia-greeter

        # === Browsers ===
        zen-browser-bin thorium-browser-avx2-bin

        # === Audio Stack ===
        pipewire pipewire-pulse pipewire-alsa wireplumber
        alsa-utils sof-firmware pavucontrol easyeffects lsp-plugins
        mpd mpd-mpris rmpc mpv mpv-mpris ffmpeg ffmpegthumbnailer
        spotify spicetify-cli cava

        # === Fonts ===
        apple-fonts inter-font ttf-roboto ttf-twemoji
        noto-fonts noto-fonts-cjk noto-fonts-emoji
        ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common

        # === Shell & Terminal ===
        fish fisher atuin zoxide starship kitty

        # === CLI Tools (AI + Personal) ===
        ast-grep dust procs jc go-yq htmlq ripgrep-all yt-dlp
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

timing_note "packages: yay transaction" "count=${#packages[@]} ${packages[*]}"
time_step "packages: install personal and AUR package set" sudo -u builder yay -S --noconfirm --needed "${packages[@]}"

echo "==> Relocating /opt to /usr/lib/opt for OSTree persistence..."
relocate_opt() {
    mkdir -p /usr/lib/opt
    if [ -n "$(fd --max-depth 1 --min-depth 1 . /opt)" ]; then
        cp -a /opt/. /usr/lib/opt/
    fi
    rm -rf /opt
    mkdir -p /opt
}
time_step "packages: relocate /opt into immutable image" relocate_opt

echo "==> Personal packages installed."

echo "==> Removing obsolete packages from the base image..."
time_shell "packages: remove global openclaw installation" 'npm uninstall -g openclaw 2>/dev/null || true'

obsolete=()
for package in nodejs npm go obs-studio rpm-tools; do
    pacman -Qq "$package" &>/dev/null && obsolete+=("$package")
done

if [ ${#obsolete[@]} -gt 0 ]; then
    time_step "packages: remove obsolete base packages" pacman -Rns --noconfirm "${obsolete[@]}"
fi
