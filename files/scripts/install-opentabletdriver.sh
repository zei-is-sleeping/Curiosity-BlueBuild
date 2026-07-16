#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest OpenTabletDriver RPM from GitHub..."
OTD_URL=$(curl -s https://api.github.com/repos/OpenTabletDriver/OpenTabletDriver/releases/latest | jq -r '.assets[] | select(.name | test("x86_64\\.rpm$")) | .browser_download_url' | head -n 1)

curl -sL "$OTD_URL" -o /tmp/opentabletdriver.rpm
dnf install -y --setopt=tsflags=noscripts /tmp/opentabletdriver.rpm
rm -f /tmp/opentabletdriver.rpm
