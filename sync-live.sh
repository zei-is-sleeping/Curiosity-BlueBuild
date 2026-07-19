#!/usr/bin/env bash
set -euo pipefail

echo "==> Violating immutable OS principles... syncing local etc to live /etc..."

# Ensure we are in the right directory
if [ ! -d "files/system/etc" ]; then
    echo "Error: Run this from the root of your BlueBuild repository."
    exit 1
fi

# The trailing slash on the source is CRITICAL so it dumps contents into /etc
# --chown=root:root ensures you don't accidentally break system permissions with your local user
sudo rsync -aiv --chown=root:root files/system/etc/ /etc/

echo "==> Sync complete."
echo "==> WARNING: Daemons do not auto-reload. You may need to run:"
echo "    sudo systemctl daemon-reload"
echo "    sudo systemctl restart NetworkManager"
