#!/bin/bash

# AUR Package Installer Script
# This script installs all packages from aur-pkglist.txt using yay
# It asks for sudo password once at the beginning

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PKGLIST="$SCRIPT_DIR/aur-pkglist.txt"

# Check if package list exists
if [[ ! -f "$PKGLIST" ]]; then
    echo "Error: $PKGLIST not found!"
    exit 1
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please install yay first."
    exit 1
fi

# Validate sudo credentials upfront (ask password once)
echo "Please enter your password to continue..."
sudo -v

# Keep sudo credentials alive in the background
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Read packages from file and install
echo "Installing AUR packages from $PKGLIST..."
echo "========================================="

# Filter out empty lines and install packages one by one
while IFS= read -r package || [[ -n "$package" ]]; do
    # Skip empty lines
    [[ -z "$package" ]] && continue

    echo ""
    echo ">>> Installing: $package"
    echo "-------------------------------------------"
    yay -S --noconfirm --needed "$package"

    if [[ $? -eq 0 ]]; then
        echo "✓ $package installed successfully"
    else
        echo "✗ Failed to install $package"
    fi
done < "$PKGLIST"

echo ""
echo "========================================="
echo "✅ Installation complete! 🚀"
