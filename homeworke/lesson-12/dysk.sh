#!/bin/bash

file_system_types=("ext4" "ext3" "ext2" "btrfs" "xfs" "ntfs" "ntfs3" "exfat")

show_all=0
if [[ "$1" == "-a" ]]; then
    show_all=1
    shift
fi
percentage_threshold="${1:-85}"

df -h -T | awk -v threshold="$percentage_threshold" -v show_all="${show_all}" -v types="${file_system_types[*]}" '
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
        if (!allowed[$2] && !show_all) {
            next
        }
        if (usage+0 >= threshold) {
            printf "\033[31m%s\033[0m\n", $0
            status = 1
        } else if (show_all) {
            print
        }
    }
    END {
        exit status
    }'

