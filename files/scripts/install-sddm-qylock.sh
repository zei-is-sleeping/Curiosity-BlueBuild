#!/usr/bin/env bash
# Non-interactive installer for the qylock SDDM theme.
# Hardcoded: Qt6 backend, "girl-pillow" theme.
# Runs during the BlueBuild image build (as root), so no sudo needed.
set -oue pipefail

QYLOCK_THEME="girl-pillow"
TARBALL_URL="https://github.com/Darkkal44/qylock/archive/refs/heads/main.tar.gz"
SYSTEM_THEMES_DIR="/usr/share/sddm/themes"
SDDM_CONF_DIR="/etc/sddm.conf.d"
SDDM_CONF="${SDDM_CONF_DIR}/theme.conf"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

echo "==> Downloading qylock..."
curl -fsSL "$TARBALL_URL" -o "$WORK_DIR/qylock.tar.gz"
tar -xzf "$WORK_DIR/qylock.tar.gz" -C "$WORK_DIR"

QYLOCK_DIR="$WORK_DIR/qylock-main"
THEMES_DIR="$QYLOCK_DIR/themes"

if [ ! -d "$THEMES_DIR/$QYLOCK_THEME" ]; then
    echo "ERROR: theme '$QYLOCK_THEME' not found under $THEMES_DIR" >&2
    exit 1
fi

echo "==> Installing theme '$QYLOCK_THEME'..."
mkdir -p "$SYSTEM_THEMES_DIR"
rm -rf "${SYSTEM_THEMES_DIR:?}/${QYLOCK_THEME:?}"
cp -r "$THEMES_DIR/$QYLOCK_THEME" "$SYSTEM_THEMES_DIR/$QYLOCK_THEME"

echo "==> Setting as active SDDM theme..."
mkdir -p "$SDDM_CONF_DIR"
if [ ! -f "$SDDM_CONF" ]; then
    printf '[Theme]\nCurrent=%s\n' "$QYLOCK_THEME" > "$SDDM_CONF"
elif grep -q '^Current=' "$SDDM_CONF"; then
    sed -i "s|^Current=.*|Current=$QYLOCK_THEME|" "$SDDM_CONF"
elif grep -q '^\[Theme\]' "$SDDM_CONF"; then
    sed -i "/^\[Theme\]/a Current=$QYLOCK_THEME" "$SDDM_CONF"
else
    printf '\n[Theme]\nCurrent=%s\n' "$QYLOCK_THEME" >> "$SDDM_CONF"
fi

echo "==> qylock theme '$QYLOCK_THEME' installed."
