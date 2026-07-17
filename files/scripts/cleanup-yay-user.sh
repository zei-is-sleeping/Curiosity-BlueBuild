#!/usr/bin/env bash
set -euo pipefail

echo "==> Nuke from orbit: Commencing final system cleanup..."

# 1. Kill any lingering builder processes just in case makepkg spawned a ghost
pkill -u builder || true

# 2. Completely obliterate the builder user (purges from /etc/passwd and /etc/shadow)
userdel -r builder || true

# 3. Remove the passwordless sudo bypass (CRITICAL SECURITY RISK IF LEFT)
rm -f /etc/sudoers.d/builder-nopasswd

# 4. Aggressively clean pacman caches
# This wipes downloaded packages and unused sync databases to shrink image size
echo "==> Emptying pacman cache..."
pacman -Scc --noconfirm

# 5. Clean up /tmp garbage
# (This catches the cachyos-repo tarballs, installer scripts, and any lingering git clones)
echo "==> Sweeping /tmp..."
rm -rf /tmp/* || true

# 6. Clear systemd journal logs generated during the container build
echo "==> Clearing build logs..."
rm -rf /var/log/journal/* || true
rm -rf /run/log/journal/* || true

echo "==> Cleanup complete. Your atomic image is mathematically pristine."
