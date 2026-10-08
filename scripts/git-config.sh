#!/bin/bash

personal_data=("Konrad_proxmox" "konradbarczak@onet.pl")

echo "=========================================="
echo " Configuring Git global settings..."
echo "=========================================="

if command -v git >/dev/null 2>&1; then
    # Konfiguracja danych użytkownika
    git config --global user.name "${personal_data[0]}" || echo "-> Warning: Failed to set user.name"
    git config --global user.email "${personal_data[1]}" || echo "-> Warning: Failed to set user.email"

    # Aliasy Git
    git config --global alias.s "status -s" || true
    git config --global alias.lg "log --oneline --graph --decorate" || true
    git config --global alias.amend "commit --amend --no-edit" || true
    git config --global alias.undo "reset HEAD~1 --mixed" || true

    echo "Git configuration completed successfully."
else
    echo "-> Error: Git is not installed, skipping configuration."
    exit 1
fi
