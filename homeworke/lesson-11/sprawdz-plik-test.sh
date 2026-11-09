#!/bin/bash

failed=0

prepare() {
  : > empty
  : > no-read
  chmod 000 no-read
}

clean() {
  chmod u+w no-read
  rm -f empty no-read
}

expect() {
  local name="$1"
  local expected_code="$2"
  shift 2

  ./sprawdz-plik.sh "$@" >/dev/null 2>&1
  local code=$?

  if [[ "$code" -eq "$expected_code" ]]; then
    echo "${name} -> OK"
  else
    echo "${name} -> FAIL (code ${code}, expected ${expected_code})"
    failed=1
  fi
}

prepare

expect "no argument"        2
expect "missing path"       1 "no-such-file"
expect "not a regular file" 3 "."
expect "empty file"         4 "empty"
expect "no read permission" 5 "no-read"
expect "valid file"         0 "sprawdz-plik.sh"
expect "too many arguments" 6 "empty" "extra"

clean

exit "$failed"
