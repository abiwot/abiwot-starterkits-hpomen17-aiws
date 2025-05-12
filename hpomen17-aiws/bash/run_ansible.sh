#!/bin/bash

############################################
# Script to run Ansible playbooks after setting up the virtual environment
#
# Purpose: This script activates the Ansible virtual environment and runs the main playbook.
#
# Usage: bash run_ansible.sh [-t|--tags <tags>] [-d|--debug <level>] [-h|--help]
#
# Change Log:
# 2025-01-04 - Initial version
# 2025-04-06 - Updated to use .yaml file extensions
# 2025-04-06 - Added debug mode option
#
############################################

# Default values
tags=""
debug_level=""
python_venv_export_file="/tmp/.ANSIBLE_VENV_PATH"

# Show help and usage information
show_help() {
  echo "Usage: $0 [-t|--tags <tags>] [-d|--debug <level>] [-h|--help]"
  echo "  -t, --tags       Specify tags to run specific roles (comma-separated, no spaces)"
  echo "  -d, --debug      Run Ansible in debug mode with specified verbosity level (1-3)"
  echo "                   Example: -d 2 (equivalent to ansible-playbook -vv)"
  echo "  -h, --help       Show this help message and exit"
  exit 0
}

# Process command-line arguments
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -t|--tags)
      tags="$2"
      shift 2
      ;;
    -d|--debug)
      debug_level="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      # Unknown option
      echo "Unknown option: $key"
      show_help
      ;;
  esac
done

# Check if the Python venv path file exists
if [ -f "$python_venv_export_file" ]; then
  venv_path=$(cat "$python_venv_export_file")
  echo "Found Python venv path: $venv_path"
else
  # If not found, use the default path from ansible_venv_install.sh
  venv_path="/app/python/venv"
  echo "Using default Python venv path: $venv_path"
fi

# Check if the venv directory exists
if [ ! -d "$venv_path" ]; then
  echo "ERROR: Python virtual environment not found at $venv_path"
  echo "Please run ansible_venv_install.sh first to set up the environment."
  exit 1
fi

# Activate the virtual environment
echo "Activating Python virtual environment..."
source "$venv_path/bin/activate"

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to activate Python virtual environment."
  exit 2
fi

# Check if Ansible is installed
if ! command -v ansible &>/dev/null; then
  echo "ERROR: Ansible not found in the virtual environment."
  echo "Please run ansible_venv_install.sh first to install Ansible."
  exit 3
fi

# Run the Ansible playbook
echo "Running Ansible playbook..."
cd "$(dirname "$0")/.." || exit 4

# Set verbosity flag based on debug level
verbosity=""
if [ -n "$debug_level" ]; then
  case "$debug_level" in
    1) verbosity="-v" ;;
    2) verbosity="-vv" ;;
    3) verbosity="-vvv" ;;
    *) echo "Invalid debug level: $debug_level. Using default verbosity." ;;
  esac
  
  if [ -n "$verbosity" ]; then
    echo "Running with verbosity level: $verbosity"
  fi
fi

# Execute ansible-playbook with appropriate options
if [ -z "$tags" ]; then
  if [ -n "$verbosity" ]; then
    ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml $verbosity
  else
    ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml
  fi
else
  if [ -n "$verbosity" ]; then
    ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml --tags "$tags" $verbosity
  else
    ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml --tags "$tags"
  fi
fi

playbook_exit_code=$?

# Deactivate the virtual environment
deactivate

# Return the exit code from the playbook
exit $playbook_exit_code