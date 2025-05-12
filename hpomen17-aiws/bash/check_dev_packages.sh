#!/bin/bash

############################################
# Script to check development packages installation
#
# Purpose: This script checks if all development packages are properly installed.
#
# Usage: bash check_dev_packages.sh
#
# Change Log:
# 2025-01-04 - Initial version
#
############################################

echo "Checking development packages installation..."
echo "--------------------------------------------"

# Function to check if a command is available
check_command() {
    local cmd=$1
    local name=$2
    
    echo -n "Checking $name... "
    if command -v "$cmd" &>/dev/null; then
        echo "INSTALLED"
        return 0
    else
        echo "NOT FOUND"
        return 1
    fi
}

# Function to check if a package is installed via apt
check_apt_package() {
    local pkg=$1
    local name=$2
    
    echo -n "Checking $name... "
    if dpkg -l | grep -q "$pkg"; then
        echo "INSTALLED"
        return 0
    else
        echo "NOT FOUND"
        return 1
    fi
}

# Check basic development tools
echo ""
echo "Basic development tools:"
check_command gcc "GCC"
check_command g++ "G++"
check_command make "Make"
check_command cmake "CMake"
check_command pkg-config "pkg-config"
check_command python3 "Python 3"
check_command pip3 "pip3"

# Check Go installation
echo ""
echo "Go installation:"
if check_command go "Go"; then
    echo "Go version: $(go version)"
fi

# No checks for VS Code, Brave Browser, or Tabby Terminal as they've been removed

# Check vim installation and configuration
echo ""
echo "Vim installation and configuration:"
if check_command vim "Vim"; then
    echo "Vim version: $(vim --version | head -n 1)"
    
    echo -n "Checking vim configuration... "
    if [ -f "/etc/vim/vimrc.local" ]; then
        echo "CONFIGURED"
        echo "Vim configuration file content:"
        echo "-----------------------------"
        cat /etc/vim/vimrc.local
        echo "-----------------------------"
    else
        echo "NOT CONFIGURED"
    fi
fi

echo ""
echo "--------------------------------------------"
echo "Check complete."