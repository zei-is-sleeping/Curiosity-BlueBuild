#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest surge release..."
SURGE_URL=$(curl -s https://api.github.com/repos/SurgeDM/Surge/releases/latest | jq -r '.assets[] | select(.name | test("linux_amd64.*tar.gz$")) | .browser_download_url' | head -n 1)
curl -sL "$SURGE_URL" | tar -xz -C /tmp
find /tmp -type f -iname "surge" -exec mv {} /usr/bin/surge \;
chmod +x /usr/bin/surge
