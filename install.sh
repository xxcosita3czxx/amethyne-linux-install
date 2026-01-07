#!/bin/bash

#if root user, exit
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root. Exiting."
    exit 1
fi

# Parse arguments
no_rm=false

for arg in "$@"; do
    if [ "$arg" == "--no-rm" ]; then
        no_rm=true
    fi
done

# Check if the system is running Arch Linux
if ! grep -q "Arch" /etc/os-release; then
    read -p "This script is intended for Arch Linux systems only. You sure you want to continue? (y/n) " arch_confirmation
    if [ "$arch_confirmation" != "y" ]; then
        echo "Exiting."
        exit 1
    fi
fi

echo "###########################################"
echo "#                                         #"
echo "#      Welcome to the Amethyne Linux      #"
echo "#           Installation Script           #"
echo "#                                         #"
echo "###########################################"

echo -e "\nStarting installation process...\n"
read -p "You really sure you wanna install Amethyne Linux?\n WARNING: This needs to be clean minimal archinstall (y/n) " confirmation

if [ "$confirmation" != "y" ]; then
    echo "Installation aborted."
    exit 1
fi

echo "Updating system packages..."
sudo pacman -Syu --noconfirm

## DEPENDENCIES ##

echo "Checking necessary dependencies..."
if $(git --version) &> /dev/null; then
    echo "Git is already installed."
else
    echo "Git is not installed. Installing Git..."
    sudo pacman -S git --noconfirm
fi

echo "Cloning Amethyne Linux repository..."
temp=$(mktemp -d)
git clone https://github.com/xxcosita3czxx/amethyne-linux-install.git "$temp"/amethyne-linux-install

echo "Installing Base Packages..."
packages_file="$temp"/amethyne-linux-install/base.x86_64
if [ -f "$packages_file" ]; then
    sudo pacman -S --noconfirm - < "$packages_file"
else
    echo "Packages file not found! Exiting."
    exit 1
fi

echo "Installing AUR packages helper (yay)..."
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git "$temp"/yay
    cd "$temp"/yay
    makepkg -si --noconfirm
    cd -
else
    echo "yay is already installed."
fi


echo "Installing Applications..."
apps_file="$temp"/amethyne-linux-install/apps.x86_64
if [ -f "$apps_file" ]; then
    sudo pacman -S --noconfirm - < "$apps_file"
else
    echo "Applications file not found! Skipping application installation."
fi

# for each service in services.x86_64, enable it
echo "Enabling Services..."
services_file="$temp"/amethyne-linux-install/services.x86_64
if [ -f "$services_file" ]; then
    while IFS= read -r service; do
        echo "Enabling service: $service"
        sudo systemctl enable $service
    done < "$services_file"
else
    echo "Services file not found! Skipping service enabling."
fi

# Cleaning up temporary files...
if [ "$no_rm" == false ]; then
    echo "Cleaning up temporary files..."
    rm -rf "$temp"
else
    echo "Skipping cleanup as --no-rm argument is provided."
fi

if [ "$no_reboot" == false ]; then
    echo "Installation complete! Rebooting system now..."
    sudo reboot
else
    echo "Installation complete! Please reboot the system manually."
fi