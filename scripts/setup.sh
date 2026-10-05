#!/bin/bash

tools=("git" "curl" "wget" "unzip" "htop" "tree" "jq")
failed_tools=()

echo "=========================================="
echo " Starting checking and installation"
echo "=========================================="

for tool in "${tools[@]}"; do
	echo -n "Checking tool: $tool ... "
	if command -v "$tool" 1>/dev/null 2>&1; then
		echo "[OK - Already installed]"
	else
		echo "[MISSING] -> Starting installation..."
		sudo apt-get update -qq && sudo apt-get install -y "$tool" >/dev/null 2>&1 || true
		if command -v "$tool" &> /dev/null; then
              	         echo "-> Success: $tool has been successfully installed."
        	else
            		echo "-> Error: Failed to install $tool."
           	        failed_tools+=("$tool")
       	 	fi
	fi
done

echo "Process completed."
if [ ${#failed_tools[@]} -gt 0 ]; then
    echo "⚠ Warning: The following tools could not be installed: ${failed_tools[@]}"
    exit 1
else
    echo "All tools are ready to work!"
fi
