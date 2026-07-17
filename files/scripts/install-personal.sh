#!/usr/bin/env bash
set -euo pipefail

echo "==> Preparing builder environment for personal packages..."

# Recreate the builder's home directory if the OCI runtime wiped it between layers
if [ ! -d "/var/home/builder" ]; then
    echo "==> /var/home/builder missing. Recreating due to OCI VOLUME purge..."
    mkdir -p /var/home/builder
    chown builder:builder /var/home/builder
fi

# This allows proprietary AUR packages (Spotify, Vesktop, FDM) to install directly into the image
if [ -L "/opt" ]; then
    echo "==> Removing /opt symlink to allow proprietary AUR installations..."
    rm -f /opt
    mkdir -p /opt
fi

echo "==> Installing personal AUR packages..."

# Run the installation as the builder user
sudo -u builder bash -c '
    # Your vertical OCD list
    packages=(
        mcontrolcenter
        msi-ec-dkms-git
        kitty
        github-cli
        power-profiles-daemon 
        bluez
        bluez-utils
        blueman
        mpd
        mpd-mpris
        mpv
        ffmpeg
        ffmpegthumbnailer
        pavucontrol 
        nvidia-prime 
        atuin 
        pipewire
        pipewire-pulse 
        zoxide 
        fish 
        fisher 
        rnote 
        opentabletdriver
        p7zip 
        firefox-pure 
        sddm 
        aria2 
        freedownloadmanager
        gdu
        spotify 
        spicetify-cli 
        vesktop
        inxi 
        lshw 
        lm_sensors 
        nvtop 
        iputils 
        smartmontools 
        nvidia-utils 
        bind-utils 
        iproute 
        nmap 
        iproute 
        gamemode 
        gamescope
        wine-cachyos 
        winetricks 
        rmpc 
        gogcli 
        surge
    )
    
    # Pipe yes into yay to automatically handle virtual provider prompts
    if [ ${#packages[@]} -gt 0 ]; then
        yes "" | yay -S --noconfirm --needed "${packages[@]}"
    else
        echo "No personal packages defined. Skipping."
    fi
'

echo "==> Personal packages installed."
