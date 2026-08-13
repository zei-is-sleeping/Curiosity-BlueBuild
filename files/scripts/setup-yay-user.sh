#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/curiosity-build/timing.sh
timing_start_script setup-yay-user

echo "==> Optimizing makepkg.conf for Lightning Builds..."
configure_makepkg() {
    cat >> /tmp/tmp.40DlQq5NQX/makepkg.conf <<'EOF'

# Curiosity image-build overrides. Later assignments override Arch defaults.
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug !lto)
LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now -Wl,-mllvm -Wl,-instcombine-lower-dbg-declare=0 -fuse-ld=mold"
RUSTFLAGS="-C opt-level=2 -C target-cpu=native -C link-arg=-fuse-ld=mold"
MAKEFLAGS="-j$(nproc)"
EOF
}
time_step "builder: configure makepkg" configure_makepkg

echo "==> Creating builder user for AUR..."
# Create user with a home directory (which will map to /var/home/builder)
create_builder() {
    useradd -m -G wheel builder
    printf 'builder ALL=(ALL) NOPASSWD: ALL\n' > /etc/sudoers.d/builder-nopasswd
    chmod 0440 /etc/sudoers.d/builder-nopasswd
}
time_step "builder: create temporary AUR user" create_builder

echo "==> Repository-provided yay is ready."
