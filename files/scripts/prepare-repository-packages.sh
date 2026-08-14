#!/usr/bin/env bash
set -euo pipefail

source /usr/lib/zeit-build/timing.sh
timing_start_script prepare-repository-packages

prepare_opt() {
    if [ -L /opt ]; then
        echo "==> Replacing the immutable /opt symlink for package installation..."
        rm -f /opt
        mkdir -p /opt
    fi
}
time_step "packages: prepare /opt for repository packages" prepare_opt
