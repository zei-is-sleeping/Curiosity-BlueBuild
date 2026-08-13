#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/curiosity-build/timing.sh
timing_start_script manage-package-cache-hooks

override_dir=/etc/pacman.d/hooks
marker=/usr/share/curiosity-build/package-cache-hooks-deferred
hooks=(
    30-update-mime-database.hook
    90-update-appstream-cache.hook
    dconf-update.hook
    fontconfig-32.hook
    fontconfig.hook
    gdk-pixbuf-query-loaders.hook
    gio-querymodules-32.hook
    gio-querymodules.hook
    gio-remove-module-cache-32.hook
    gio-remove-module-cache.hook
    glib-compile-schemas.hook
    glib-remove-compiled-schemas.hook
    gtk-query-immodules-3.0.hook
    gtk-update-icon-cache.hook
    gtk4-querymodules.hook
    shared-mime-info-remove-cache.hook
    update-desktop-database.hook
)

defer_hooks() {
    local hook override
    mkdir -p "$override_dir"
    for hook in "${hooks[@]}"; do
        override="$override_dir/$hook"
        if [ -e "$override" ] || [ -L "$override" ]; then
            echo "ERROR: Refusing to replace existing pacman hook override: $override" >&2
            return 1
        fi
        # Some hook providers are installed by later categories, so mask them preemptively.
        ln -s /dev/null "$override"
    done
    touch "$marker"
}

restore_hooks() {
    local hook
    for hook in "${hooks[@]}"; do
        rm -f "$override_dir/$hook"
    done
    rm -f "$marker"
}

refresh_icon_caches() {
    local theme
    for theme in /usr/share/icons/*/; do
        if [ -f "${theme}index.theme" ]; then
            gtk-update-icon-cache -q "$theme"
        fi
    done
}

refresh_desktop_caches() {
    command -v update-desktop-database >/dev/null && update-desktop-database --quiet
    command -v update-mime-database >/dev/null && env PKGSYSTEM_ENABLE_FSYNC=0 update-mime-database /usr/share/mime
    command -v glib-compile-schemas >/dev/null && glib-compile-schemas /usr/share/glib-2.0/schemas
    [ ! -x /usr/share/libalpm/scripts/dconf-update ] || /usr/share/libalpm/scripts/dconf-update
}

refresh_module_caches() {
    if [ -d /usr/lib/gio/modules ] && command -v gio-querymodules >/dev/null; then
        gio-querymodules /usr/lib/gio/modules
    fi
    if [ -d /usr/lib32/gio/modules ] && command -v gio-querymodules-32 >/dev/null; then
        gio-querymodules-32 /usr/lib32/gio/modules
    fi
    command -v gdk-pixbuf-query-loaders >/dev/null && gdk-pixbuf-query-loaders --update-cache
    command -v gtk-query-immodules-3.0 >/dev/null && gtk-query-immodules-3.0 --update-cache
    [ ! -x /usr/share/libalpm/scripts/gtk4-querymodules ] || /usr/share/libalpm/scripts/gtk4-querymodules
}

refresh_font_caches() {
    command -v fc-cache >/dev/null && fc-cache -s
    if command -v fc-cache-32 >/dev/null; then
        fc-cache-32 -s
    fi
}

refresh_appstream_cache() {
    if command -v appstreamcli >/dev/null; then
        appstreamcli refresh-cache --force
    fi
}

if [ ! -e "$marker" ]; then
    echo "==> Deferring regenerable package caches until repository packages are installed..."
    time_step "packages: defer regenerable pacman hooks" defer_hooks
else
    echo "==> Restoring package hooks and regenerating deferred caches..."
    time_step "packages: restore deferred pacman hooks" restore_hooks
    time_step "packages: regenerate icon caches" refresh_icon_caches
    time_step "packages: regenerate desktop and MIME caches" refresh_desktop_caches
    time_step "packages: regenerate GUI module caches" refresh_module_caches
    time_step "packages: regenerate font caches" refresh_font_caches
    time_step "packages: regenerate appstream cache" refresh_appstream_cache
fi
