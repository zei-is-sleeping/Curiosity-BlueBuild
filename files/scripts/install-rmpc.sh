#!/usr/bin/env bash
set -euo pipefail

echo "Fetching latest rmpc release..."
RMPC_URL=$(curl -s https://api.github.com/repos/mierak/rmpc/releases/latest | jq -r '.assets[] | select(.name | test("x86_64.*linux.*tar.gz$")) | .browser_download_url' | head -n 1)
curl -sL "$RMPC_URL" | tar -xz -C /tmp
find /tmp -type f -name "rmpc" -exec mv {} /usr/bin/rmpc \;
chmod +x /usr/bin/rmpc
