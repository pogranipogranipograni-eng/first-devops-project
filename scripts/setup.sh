#!/bin/bash

tools=("git" "curl" "wget" "unzip" "htop" "tree" "jq")
failed_tools=()

echo "=========================================="
echo " Rozpoczynam sprawdzanie i instalację"
echo "=========================================="

for tool in "${tools[@]}"; do
	echo -n "Sprawdzam narzędzie: $tool ... "
	if command -v "$tool" 1>/dev/null 2>&1; then
		echo "[OK - Już zainstalowane]"
	else
		echo "[BRAK] -> Rozpoczynam instalację..."
		sudo apt-get update -qq && sudo apt-get install -y "$tool" >/dev/null 2>&1 || true
		if command -v "$tool" &> /dev/null; then
              	         echo "-> Sukces: $tool został poprawnie zainstalowany."
        	else
            		echo "-> Błąd: Nie udało się zainstalować $tool."
           	        failed_tools+=("$tool")
       	 	fi
	fi
done

echo "Proces zakończony."
if [ ${#failed_tools[@]} -gt 0 ]; then
    echo "⚠ Uwaga: Następujące narzędzia nie mogły zostać zainstalowane: ${failed_tools[@]}"
    exit 1
else
    echo "Wszystkie narzędzia są gotowe do pracy!"
fi
