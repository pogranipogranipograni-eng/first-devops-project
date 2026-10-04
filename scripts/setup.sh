#!/bin/bash

tools=("git" "curl" "wget" "unzip" "htop" "tree" "jq" "docker" "dupa" )

echo "=========================================="
echo " Start instalation: ${programs[@]}"
echo "=========================================="

for tool in "${tools[@]}"; do
	echo -n "Sprawdzam narzędzie: $tool ... "
	if command -v "$tool" 1>/dev/null 2>&1; then
		echo "[OK - Już zainstalowane]"
	else
		echo $?
	fi
done
