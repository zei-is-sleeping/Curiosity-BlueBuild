#!/usr/bin/env bash

: "${TIMING_DIR:=/usr/share/curiosity-build}"
: "${TIMING_LOG:=$TIMING_DIR/timings.tsv}"

mkdir -p "$TIMING_DIR"

timing_start_script() {
    TIMING_SCRIPT=$1
    TIMING_SCRIPT_STARTED=$(date +%s%N)
    trap 'status=$?; trap - EXIT; timing_finish_script "$status"; exit "$status"' EXIT
}

timing_finish_script() {
    local status=$1
    local finished
    finished=$(date +%s%N)
    printf '%s\t%s\tscript: %s\t\n' \
        "$(((finished - TIMING_SCRIPT_STARTED) / 1000000))" "$status" "$TIMING_SCRIPT" >> "$TIMING_LOG"
}

timing_note() {
    local label=$1
    local detail=${2:-}
    detail=${detail//$'\t'/ }
    detail=${detail//$'\n'/ }
    printf '0\t0\t%s\t%s\n' "$label" "$detail" >> "$TIMING_LOG"
}

time_step() {
    local label=$1
    shift

    local started finished status
    started=$(date +%s%N)
    if "$@"; then
        status=0
    else
        status=$?
    fi
    finished=$(date +%s%N)

    printf '%s\t%s\t%s\t\n' "$(((finished - started) / 1000000))" "$status" "$label" >> "$TIMING_LOG"
    return "$status"
}

time_shell() {
    local label=$1
    local command=$2
    local started finished status

    started=$(date +%s%N)
    if bash -o pipefail -c "$command"; then
        status=0
    else
        status=$?
    fi
    finished=$(date +%s%N)

    printf '%s\t%s\t%s\t\n' "$(((finished - started) / 1000000))" "$status" "$label" >> "$TIMING_LOG"
    return "$status"
}

write_timing_report() {
    local report="$TIMING_DIR/blame.txt"

    {
        printf 'Curiosity image build timing (slowest first)\n'
        printf 'Cached layers retain the timing from the build that produced them.\n'
        printf 'milliseconds\tstatus\tstep\tdetail\n'
        sort -t $'\t' -k1,1nr "$TIMING_LOG"
    } > "$report"
}

write_package_report() {
    local report="$TIMING_DIR/packages.txt"

    {
        printf 'Curiosity packages present at the end of the image build (largest first)\n'
        printf 'installed_bytes\tpackage\tversion\n'
        expac -Q '%m\t%n\t%v' | sort -t $'\t' -k1,1nr
    } > "$report"
}
