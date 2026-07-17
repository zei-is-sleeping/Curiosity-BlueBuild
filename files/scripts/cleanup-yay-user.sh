#!/usr/bin/env bash
set -euo pipefail

echo "==> Nuke from orbit: Commencing final system cleanup..."

# 1. Kill any lingering builder processes
pkill -u builder || true

# 2. Completely obliterate the builder user
userdel -r builder || true

# 3. Remove the passwordless sudo bypass
rm -f /etc/sudoers.d/builder-nopasswd

# 4. Aggressively clean pacman caches manually
echo "==> Emptying pacman cache..."
rm -rf /usr/lib/sysimage/cache/pacman/pkg/* || true
rm -rf /var/cache/pacman/pkg/* || true

# 5. Clear systemd journal logs
echo "==> Clearing build logs..."
rm -rf /var/log/journal/* || true
rm -rf /run/log/journal/* || true

echo "==> Cleanup complete. Your atomic image is mathematically pristine."
