#!/bin/bash

############################################
# Main setup script for Ubuntu 24.04 Development Environment
#
# Purpose: This script runs all the necessary steps to configure
#          an Ubuntu 24.04 laptop for development and running LLMs locally.
#
# Usage: bash setup.sh [-h|--help] [-d|--debug [level]]
#
# Change Log:
# 2025-01-04 - Initial version
# 2025-04-06 - Added debug mode option
#
############################################

# Default values
debug_level=""

# Show help and usage information
show_help() {
  echo "Ubuntu 24.04 Development Environment Setup"
  echo ""
  echo "This script automates the initial configuration of a laptop environment"
  echo "running Ubuntu 24.04 desktop for development and running LLMs locally."
  echo ""
  echo "Usage: $0 [-h|--help] [-d|--debug [level]]"
  echo "  -h, --help       Show this help message and exit"
  echo "  -d, --debug      Run Ansible in debug mode with specified verbosity level (1-3)"
  echo "                   Example: -d 2 (equivalent to ansible-playbook -vv)"
  echo ""
  echo "The script will:"
  echo "1. Install Ansible in a Python virtual environment"
  echo "2. Run Ansible playbooks to configure the system:"
  echo "   - Install NVIDIA drivers and CUDA"
  echo "   - Install basic packages"
  echo "   - Configure SSH keys"
  echo "   - Install development packages"
  echo "   - Configure vim"
  echo ""
  echo "After completion, you can run the check scripts to verify the installation:"
  echo "- bash/check_nvidia.sh: Check NVIDIA drivers and CUDA installation"
  echo "- bash/check_dev_packages.sh: Check development packages installation"
  exit 0
}

# Process command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -h|--help)
      show_help
      ;;
    -d|--debug)
      if [[ $2 =~ ^[1-3]$ ]]; then
        debug_level=$2
        shift
      else
        debug_level=1
      fi
      shift
      ;;
    *)
      # Unknown option
      echo "Unknown option: $key"
      show_help
      ;;
  esac
done

# Get the script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$(id -u)" -eq 0 ]; then
  echo "ERROR: This script should not be run as root."
  echo "Please run as a regular user with sudo privileges."
  exit 1
fi

# Check if running on Ubuntu 24.04
if [ -f /etc/os-release ]; then
  . /etc/os-release
  if [ "$ID" != "ubuntu" ] || [ "$VERSION_ID" != "24.04" ]; then
    echo "WARNING: This script is designed for Ubuntu 24.04."
    echo "Current OS: $PRETTY_NAME"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      exit 1
    fi
  fi
else
  echo "WARNING: Unable to determine OS version."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Check for sudo privileges
echo "Checking for sudo privileges..."
if sudo -v; then
  echo "Sudo privileges confirmed."
else
  echo "ERROR: This script requires sudo privileges."
  exit 1
fi

# Step 1: Install Ansible in a Python virtual environment
echo ""
echo "Step 1: Installing Ansible in a Python virtual environment..."
echo "============================================================"
bash "$script_dir/bash/ansible_venv_install.sh"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to install Ansible."
  exit 1
fi
echo "Ansible installation completed."

# Step 2: Run Ansible playbooks
echo ""
echo "Step 2: Running Ansible playbooks..."
echo "==================================="
if [ -n "$debug_level" ]; then
  echo "Running in debug mode with verbosity level $debug_level"
  bash "$script_dir/bash/run_ansible.sh" -d "$debug_level"
else
  bash "$script_dir/bash/run_ansible.sh"
fi

if [ $? -ne 0 ]; then
  echo "ERROR: Ansible playbooks execution failed."
  exit 1
fi
echo "Ansible playbooks execution completed."

# Step 3: Verify installation
echo ""
echo "Step 3: Verifying installation..."
echo "================================"
echo "You can run the following scripts to verify the installation:"
echo "- bash/check_nvidia.sh: Check NVIDIA drivers and CUDA installation"
echo "- bash/check_dev_packages.sh: Check development packages installation"

echo ""
echo "Setup completed successfully!"
echo "Please reboot your system to ensure all changes take effect."