#!/usr/bin/env bash
set -euo pipefail

echo "Building app from source..."

dnf copr enable -y teackot/msi

# Prevents crashing on the automatic akmod script
dnf install -y --setopt=tsflags=noscripts akmod-acpi_ec mcontrolcenter

KERNEL_VERSION=$(rpm -q kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')

# JIC
chown -R akmods:akmods /var/cache/akmods

# Safe BUILD FOLDER
mkdir -p /tmp/msi-build
chown akmods:akmods /tmp/msi-build
cd /tmp/msi-build

# tmp and var tmp bug
chmod 1777 /tmp /var/tmp

# Generate rpms
su -s /bin/bash akmods -c "akmodsbuild --kernels ${KERNEL_VERSION} /usr/src/akmods/acpi_ec-kmod-*.src.rpm"

dnf install -y /tmp/msi-build/*.rpm

# cleanup
rm -rf /tmp/msi-build
