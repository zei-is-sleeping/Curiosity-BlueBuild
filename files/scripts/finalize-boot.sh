#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/zeit-build/timing.sh
timing_start_script finalize-boot

echo "==> Ensuring latest kernel and initramfs are in the correct bootc location..."

mapfile -t kernel_dirs < <(fd --max-depth 1 --type d 'cachyos-bore' /usr/lib/modules | sort -V)
if [ ${#kernel_dirs[@]} -eq 0 ]; then
    echo "ERROR: No CachyOS BORE kernel module directory found." >&2
    exit 1
fi

kernel_dir=${kernel_dirs[-1]}
kernel_version=${kernel_dir%/}
kernel_version=${kernel_version##*/}

kernel_source=/boot/vmlinuz-linux-cachyos-bore
initramfs_source=/boot/initramfs-linux-cachyos-bore.img
if [ ! -f "$kernel_source" ] || [ ! -f "$initramfs_source" ]; then
    echo "ERROR: CachyOS BORE boot artifacts are missing from /boot." >&2
    exit 1
fi

install_boot_artifacts() {
    cp "$kernel_source" "$kernel_dir/vmlinuz"
    cp "$initramfs_source" "$kernel_dir/initramfs.img"
}
time_step "finalize: install bootc kernel and initramfs artifacts" install_boot_artifacts
write_package_report
time_step "finalize: remove build-report dependency" pacman -Rns --noconfirm expac
timing_finish_script 0
trap - EXIT
write_timing_report

echo "==> Boot files relocated for $kernel_version."
