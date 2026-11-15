#!/bin/bash

file_system_types=("ext4" "ext3" "ext2" "btrfs" "xfs" "ntfs" "ntfs3" "exfat")

usage() {
    cat <<EOF
Usage:
    ${0##*/} [-v] [-h] [PERCENT]

Options:
    -v        print every checked filesystem type; rows at or above the threshold are red
    -h        show this help
    PERCENT   usage threshold from 0 to 100 (default: 85)

Exit codes:
    0  every checked filesystem is below the threshold
    1  at least one filesystem is at or above the threshold
    2  invalid option
EOF
}

verbose=0
while getopts ":vh" opt; do
    case "${opt}" in
        v) verbose=1 ;;
        h) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
done
shift "$((OPTIND - 1))"
percentage_threshold="${1:-85}"

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

