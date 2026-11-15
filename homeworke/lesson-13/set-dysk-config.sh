#!/bin/bash

if [[ "${1:-}" == "-h" ]]; then
    cat <<EOF
Usage:
    source ${0##*/} [FILE_THRESHOLD] [DISC_THRESHOLD]

Writes ~/.config/dysk.conf and exports DISC_THRESHOLD in this shell.
Defaults: file 50, variable 10.
EOF
    return 0 2>/dev/null || exit 0
fi

file_threshold="${1:-50}"
env_threshold="${2:-10}"
config_file="${HOME}/.config/dysk.conf"

mkdir -p "${HOME}/.config"
cat > "${config_file}" <<EOF
threshold=${file_threshold}
EOF

export DISC_THRESHOLD="${env_threshold}"

printf 'Wrote %s with threshold=%s\n' "${config_file}" "${file_threshold}"
printf 'DISC_THRESHOLD=%s\n' "${DISC_THRESHOLD}"

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'Run: source %s\n' "${0##*/}" >&2
    printf 'A direct run does not leave DISC_THRESHOLD in this terminal.\n' >&2
fi
