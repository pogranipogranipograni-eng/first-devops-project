#!/bin/bash

usage() {
     cat >&2 <<EOF
 Usage: ${0##*/} <path>

 Validates a file and returns specific exit codes:
   0 - OK (prints size and line count)
   1 - Path does not exist
   2 - Missing argument
   3 - Not a regular file
   4 - File is empty
   5 - No read permission
   6 - To many arguments

 Only one <path> is allowed.
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

if [[ $# -gt 1 ]]; then
  usage
  exit 6
fi

if [[ ! -e "$1" ]]; then
  exit 1
fi

if [[ ! -f "$1" ]]; then
  exit 3
fi

if [[ ! -r "$1" ]]; then
  exit 5
fi

if [[ ! -s "$1" ]]; then
  exit 4
fi

echo "Number on lines in ${0##*/}  $(wc -l <"$1")"
echo "File size: $(wc -c < "$1") baits"

exit 0