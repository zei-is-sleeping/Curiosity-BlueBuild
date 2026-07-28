#!/usr/bin/env bash
set -euo pipefail

echo "==> Ensuring latest kernel and initramfs are in the correct bootc location..."

# Sort by version to safely grab the newest one, ignoring any leftover DKMS folders
KVER=$(ls /usr/lib/modules | grep "cachyos-bore" | sort -V | tail -n 1)

cp /boot/vmlinuz-linux-cachyos-bore /usr/lib/modules/$KVER/vmlinuz
cp /boot/initramfs-linux-cachyos-bore.img /usr/lib/modules/$KVER/initramfs.img

echo "==> Boot files relocated for $KVER."
