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
    mkdir -p /usr/lib/opt
    ln -s usr/lib/opt /opt 

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
        btrfs-progs
        compsize
        btrfsmaintenance
        snapper
        podman
        podman-compose
        podman-docker
        fuse-overlayfs
        slirp4netns
        crun
        netavark
        aardvark-dns
        distrobox
        toolbox
        skopeo
        xorg-xhost
        flatpak

        
        cava pavucontrol-qt wireplumber pipewire-pulse libdbusmenu-gtk3 playerctl geoclue brightnessctl ddcutil bc coreutils cliphist cmake curl wget ripgrep jq xdg-user-dirs rsync go-yq adw-gtk-theme-git breeze breeze-plus darkly-bin eza fish fontconfig kitty matugen otf-space-grotesk starship ttf-jetbrains-mono-nerd ttf-material-symbols-variable-git ttf-readex-pro ttf-rubik-vf hyprland hyprsunset wl-clipboard bluedevil gnome-keyring networkmanager plasma-nm polkit-kde-agent dolphin systemsettings xdg-desktop-portal xdg-desktop-portal-kde xdg-desktop-portal-gtk xdg-desktop-portal-hyprland clang uv gtk4 libadwaita libsoup3 libportal-gtk4 gobject-introspection hyprshot slurp swappy tesseract tesseract-data-eng wf-recorder upower wtype ydotool fuzzel glib2 imagemagick hypridle hyprlock hyprpicker songrec translate-shell wlogout libqalculate

        quickshell
        plasma-browser-integration


        vivaldi 
        zen-browser-bin
        obsidian
        bootupd
        btop
        tealdeer 
        lazygit 
        unrar 
        zip 
        evtest 
        wev 
        fuse2 
        appimagelauncher
        python-pipx 
        flatseal 
        topgrade
        boxbuddy
    )
    
    # Pipe yes into yay to automatically handle virtual provider prompts
    if [ ${#packages[@]} -gt 0 ]; then
        yes "" | yay -S --noconfirm --needed "${packages[@]}"
    else
        echo "No personal packages defined. Skipping."
    fi
'

echo "==> Personal packages installed."
