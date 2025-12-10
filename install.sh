#!/bin/bash

#if root user, exit
if [ "$EUID" -eq 0 ]; then
    echo "Please do not run this script as root. Exiting."
    exit 1
fi

# Check if the system is running Arch Linux
if ! grep -q ":Arch" /etc/os-release; then
    echo "This script is intended for Arch Linux systems only. You sure you want to continue? (y/n)"
    read arch_confirmation
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


echo "\nStarting installation process...\n"
echo "You really sure you wanna install Amethyne Linux?\n WARNING: This needs to be clean minimal archinstall (y/n)"
read confirmation

if [ "$confirmation" != "y" ]; then
    echo "Installation aborted."
    exit 1
fi

echo "Updating system packages..."
sudo pacman -Syu --noconfirm

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

