#!/bin/bash

file_system_types=("ext4" "ext3" "ext2" "btrfs" "xfs" "ntfs" "ntfs3" "exfat")

usage() {
    cat <<EOF
Usage:
    ${0##*/} [-v] [-h] [--pokaz-konfiguracje] [PERCENT]

Options:
    -v                     print every checked filesystem type; rows at or above the threshold are red
    -h                     show this help
    --pokaz-konfiguracje   print the effective threshold and the layer it came from
    PERCENT                usage threshold from 0 to 100 (default: 85)

Configuration:
    DISC_THRESHOLD         environment variable that sets the threshold
    ~/.config/dysk.conf    read only when this file exists; key: threshold
    source set-dysk-config.sh [FILE] [ENV]
                           writes that file and exports DISC_THRESHOLD in this terminal

Exit codes:
    0  every checked filesystem is below the threshold
    1  at least one filesystem is at or above the threshold
    2  invalid option
EOF
}

load_config() {
    local file="$1"
    local key value
    [[ -f "${file}" ]] || return 0

    while IFS='=' read -r key value; do
        key="${key## }"; key="${key%% }"
        [[ -z "${key}" || "${key}" == \#* ]] && continue
        value="${value## }"; value="${value%% }"
        value="${value%\"}"; value="${value#\"}"
        case "${key}" in
            threshold)
                percentage_threshold="${value}"
                threshold_source="file"
                ;;
            *)
                printf 'Unknown key in %s: %s\n' "${file}" "${key}" >&2
                ;;
        esac
    done < "${file}"
}

show_configuration=0
remaining=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pokaz-konfiguracje)
            show_configuration=1
            shift
            ;;
        *)
            remaining+=("$1")
            shift
            ;;
    esac
done
if [[ ${#remaining[@]} -gt 0 ]]; then
    set -- "${remaining[@]}"
else
    set --
fi

verbose=0
while getopts ":vh" opt; do
    case "${opt}" in
        v) verbose=1 ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"
percentage_threshold=85
threshold_source="code"
load_config "${HOME}/.config/dysk.conf"
if [[ -n "${DISC_THRESHOLD:-}" ]]; then
    percentage_threshold="${DISC_THRESHOLD}"
    threshold_source="environment"
fi
if [[ -n "${1:-}" ]]; then
    percentage_threshold="$1"
    threshold_source="command line"
fi
if [[ "${show_configuration}" -eq 1 ]]; then
    printf 'threshold=%s (%s)\n' "${percentage_threshold}" "${threshold_source}"
    exit 0
fi
echo "percentage_Threshold inside scripot: $percentage_threshold"

df -h -T | awk -v threshold="$percentage_threshold" -v verbose="${verbose}" -v types="${file_system_types[*]}" '
    BEGIN {
        status = 0
        count = split(types, names, " ")
        for (i = 1; i <= count; i++) {
            allowed[names[i]] = 1
        }
    }
    NR > 1 {
        usage = $6
        sub(/%/, "", usage)
        if (!allowed[$2]) {
            next
        }
        if (usage+0 >= threshold) {
            printf "\033[31m%s\033[0m\n", $0
            status = 1
        } else if (verbose) {
            print
        }
    }
    END {
        exit status
    }'

