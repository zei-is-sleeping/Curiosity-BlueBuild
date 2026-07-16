#!/usr/bin/env bash
set -euo pipefail

echo "Fetching and installing the latest Vesktop RPM..."
curl -sL https://vencord.dev/download/vesktop/amd64/rpm -o /tmp/vesktop.rpm
dnf install -y /tmp/vesktop.rpm
rm -f /tmp/vesktop.rpm
