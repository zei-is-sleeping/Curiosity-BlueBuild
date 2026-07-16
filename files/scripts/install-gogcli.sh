#!/usr/bin/env bash
set -euo pipefail

echo "Building gogcli from source..."

# 1. Install build dependencies
dnf install -y golang make

# 2. Clone the repo
git clone https://github.com/steipete/gogcli.git /tmp/gogcli
cd /tmp/gogcli

# 3. Build using make and our Fake Home hack
HOME=/tmp make

# 4. Generate the shell completions (this requires the binary we just built to run)
./bin/gog completion bash > gog.bash
./bin/gog completion zsh > _gog
./bin/gog completion fish > gog.fish

# 5. Install the binary
install -Dm755 bin/gog -t /usr/bin/

# 6. Install the completions exactly where they belong
install -Dm644 gog.bash /usr/share/bash-completion/completions/gog
install -Dm644 _gog /usr/share/zsh/site-functions/_gog
install -Dm644 gog.fish /usr/share/fish/vendor_completions.d/gog.fish

# 7. Aggressive Cleanup
rm -rf /tmp/gogcli /tmp/go
dnf remove -y golang make
dnf clean all
