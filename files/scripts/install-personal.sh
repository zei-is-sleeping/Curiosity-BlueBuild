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

echo "==> Installing personal & Ryoku packages..."

sudo -u builder bash -c '
    packages=(
        # Your Personal Stuff
        mcontrolcenter msi-ec-dkms-git celluloid kitty github-cli power-profiles-daemon 
        bluez bluez-utils blueman mpd mpd-mpris mpv ffmpeg ffmpegthumbnailer nvidia-prime 
        atuin pipewire pipewire-pulse zoxide fish fisher rnote opentabletdriver p7zip 
        firefox-pure sddm aria2 freedownloadmanager gdu spotify spicetify-cli vesktop 
        inxi lshw lm_sensors nvtop iputils smartmontools nvidia-utils bind-utils iproute 
        nmap gamemode gamescope wine-cachyos winetricks rmpc gogcli surge btrfs-progs 
        compsize btrfsmaintenance snapper podman podman-compose podman-docker fuse-overlayfs 
        slirp4netns crun netavark aardvark-dns distrobox toolbox skopeo xorg-xhost flatpak 
        vivaldi zen-browser-bin obsidian bootupd btop tealdeer lazygit unrar zip evtest 
        wev fuse2 appimagelauncher python-pipx flatseal topgrade boxbuddy celluloid tesseract tesseract-data-eng 
        ydotool cava bc jq rsync wget wf-recorder hyprsunset 

        # Ryoku Desktop System Dependencies
        ryoku-keyring ryoku-shell ryoku-hub ryoku-blobs ryoku ryoku-desktop sddm networkmanager 
        iwd iw pipewire pipewire-alsa pipewire-pulse wireplumber mesa vulkan-icd-loader 
        xdg-user-dirs qt6ct adwaita-icon-theme vimix-cursors polkit gnome-keyring 
        qt6-declarative qt6-multimedia qt6-multimedia-ffmpeg gst-plugins-base gst-plugins-good 
        gst-plugins-bad gst-plugins-ugly upower fuzzel curl libnotify python xdg-utils 
        desktop-file-utils flatpak ffmpeg yt-dlp mpv libqalculate mpv-mpris songrec rust 
        intel-ucode go nodejs npm python python-pip python-pipx mise
        
        # Ryoku AUR Extras
        bibata-cursor-theme-bin localsend-bin voxtype-bin
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
ln -s usr/lib/opt /opt

echo "==> Personal and Ryoku packages installed."
