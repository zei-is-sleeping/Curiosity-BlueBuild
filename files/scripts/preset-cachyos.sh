#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/curiosity-build/timing.sh
timing_start_script preset-cachyos

echo "==> Unlocking pacman speed, aesthetics, and container compatibility..."
configure_pacman() {
    if ! grep -q '^DisableSandbox$' /etc/pacman.conf; then
        sed -i '/^Architecture = auto$/a DisableSandbox' /etc/pacman.conf
    fi
}
time_step "preset: configure pacman for container build" configure_pacman

echo "==> Initializing pacman keyring for third-party signatures..."
time_step "preset: initialize pacman keyring" pacman-key --init
time_step "preset: populate Arch keyring" pacman-key --populate archlinux

install_cachyos_repo() {
    local work_dir
    work_dir=$(mktemp -d)

    curl -fsSL https://mirror.cachyos.org/cachyos-repo.tar.xz -o "$work_dir/cachyos-repo.tar.xz"
    bsdtar -xf "$work_dir/cachyos-repo.tar.xz" -C "$work_dir"

    sed -i 's/local is_isa_v4_supported=.*/local is_isa_v4_supported="1"/' "$work_dir/cachyos-repo/cachyos-repo.sh"
    sed -i 's/local is_znver_supported=.*/local is_znver_supported="1"/' "$work_dir/cachyos-repo/cachyos-repo.sh"
    sed -i 's/^    pacman -Syu$/    : # Upgrade once after every repository is configured./' "$work_dir/cachyos-repo/cachyos-repo.sh"

    set +o pipefail
    yes '' | "$work_dir/cachyos-repo/cachyos-repo.sh"
    local installer_status=${PIPESTATUS[1]}
    set -o pipefail
    rm -rf "$work_dir"
    return "$installer_status"
}

echo "==> Injecting CachyOS Repositories (x86-64-v3)..."
time_step "preset: install CachyOS repositories" install_cachyos_repo

echo "==> Installing Chaotic-AUR..."
install_chaotic_aur() {
    pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
    pacman-key --lsign-key 3056513887B78AEB
    pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm
    printf '\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist\n' >> /etc/pacman.conf
}
time_step "preset: install Chaotic-AUR repository" install_chaotic_aur

echo "Installing MULTILIB"
printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf

echo "==> Optimizing Mirrors..."
time_step "preset: install mirror optimizer" pacman -Sy --noconfirm --needed rate-mirrors
optimize_mirrors() {
    rate-mirrors --allow-root arch > /etc/pacman.d/mirrorlist
}
time_step "preset: rank Arch mirrors" optimize_mirrors
time_step "preset: synchronize and upgrade base image" pacman -Syu --noconfirm --needed

echo "==> Swapping Arch kernel for CachyOS BORE..."
time_step "preset: install CachyOS BORE kernel and NVIDIA modules" pacman -S --noconfirm --needed linux-cachyos-bore linux-cachyos-bore-headers linux-cachyos-bore-nvidia-open nvidia-utils

echo "==> Purging stock Linux kernel..."
remove_stock_kernel() {
    pacman -Rns --noconfirm linux || true
    pacman -Rns --noconfirm linux-headers || true
    find /usr/lib/modules -mindepth 1 -maxdepth 1 ! -name '*cachyos*' -exec rm -rf {} +
}
time_step "preset: remove stock kernel" remove_stock_kernel

echo "==> CachyOS Presets applied successfully."
