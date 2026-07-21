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
        # Your Personal Stuff
        mcontrolcenter msi-ec-dkms-git celluloid kitty github-cli power-profiles-daemon 
        bluez bluez-utils blueman mpd mpd-mpris mpv ffmpeg ffmpegthumbnailer nvidia-prime 
        atuin pipewire pipewire-pulse zoxide fish fisher rnote opentabletdriver p7zip 
        aria2 freedownloadmanager gdu spicetify-cli vesktop 
        inxi lshw lm_sensors nvtop iputils smartmontools nvidia-utils bind-utils iproute 
        gamemode gamescope wine-cachyos winetricks rmpc surge-bin btrfs-progs 
        compsize btrfsmaintenance fuse-overlayfs 
        xorg-xhost flatpak 
        obsidian btop tealdeer lazygit unrar zip evtest 
        wev fuse2 uv flatseal celluloid tesseract tesseract-data-eng 
        ydotool cava bc jq rsync wget hyprsunset xdg-user-dirs pipewire pipewire-alsa iwd networkmanager 
        polkit gnome-keyring curl libnotify python xdg-utils flatpak ffmpeg mpv mpv-mpris songrec intel-ucode 
        hyprland cliphist wl-clipboard adw-gtk-theme wireplumber intel-media-driver vulkan-intel
        papirus-icon-theme wireguard-tools lsp-plugins firefoxpwa


        apple-fonts upower adw-gtk-theme nwg-look nwg-displays qt6ct-kde greetd noctalia-greeter-git accountsservice qt6-wayland 

        ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-common
        ttf-roboto noto-fonts noto-fonts-cjk noto-fonts-emoji 
        trash-cli plocate trippy imv httpie udiskie inter-font ttf-twemoji xdg-desktop-portal-gtk 
        ouch zram-generator easyeffects keyd 
        jujutsu

        zen-browser-bin
        thorium-browser-avx2-bin
        starship

        scx-scheds scx-tools cachyos-settings nohang fwupd bpftune
        thermald switcheroo-control nvidia-prime mold
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
