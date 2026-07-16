#!/usr/bin/env bash
set -euo pipefail

echo "Building mpd-mpris from source..."

# 1. Install build dependencies (Claude caught the gcc requirement!)
dnf install -y golang gcc glibc-devel

# 2. Clone the repo to get the source AND the systemd service file
git clone https://github.com/natsukagami/mpd-mpris.git /tmp/mpd-mpris
cd /tmp/mpd-mpris

# 3. Build it using our Fake Home hack to bypass OSTree symlinks
HOME=/tmp go build -v -buildmode=pie -mod=readonly -modcacherw -ldflags "-compressdwarf=false -linkmode external" -o build/mpd-mpris ./cmd/...

# 4. Install the binary and the Systemd User Service
install -vDm 755 build/mpd-mpris -t /usr/bin/
install -vDm 644 services/mpd-mpris.service -t /usr/lib/systemd/user/

# 5. Aggressive Cleanup
rm -rf /tmp/mpd-mpris /tmp/go
dnf remove -y golang gcc glibc-devel
dnf clean all
