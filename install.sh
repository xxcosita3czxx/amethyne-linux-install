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
    echo "This script is intended for Arch Linux systems only. You sure you want to continue? (y/n)"
    read arch_confirmation <$0
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
echo -e "You really sure you wanna install Amethyne Linux?\n WARNING: This needs to be clean minimal archinstall (y/n)"
read confirmation <$0

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
if $(curl --version) &> /dev/null; then
    echo "Curl is already installed."
else
    echo "Curl is not installed. Installing Curl..."
    sudo pacman -S curl --noconfirm
fi
if $(wget --version) &> /dev/null; then
    echo "Wget is already installed."
else
    echo "Wget is not installed. Installing Wget..."
    sudo pacman -S wget --noconfirm
fi

echo "Cloning Amethyne Linux repository..."
temp=$(mktemp -d)
git clone https://github.com/xxcosita3czxx/amethyne-linux-install.git "$temp"/amethyne-linux-install

echo "Installing Base Packages..."
packages_file="$temp"/amethyne-linux-install/packages.x86_64
if [ -f "$packages_file" ]; then
    sudo pacman -S --noconfirm - < "$packages_file"
else
    echo "Packages file not found! Exiting."
    exit 1
fi

echo "Enabling services..."
sudo systemctl enable --now NetworkManager

echo "Starting sddm service..."
sudo systemctl enable sddm

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