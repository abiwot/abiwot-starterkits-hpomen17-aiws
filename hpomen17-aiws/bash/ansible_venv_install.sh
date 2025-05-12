#!/bin/bash

############################################
# Script to install Ansible in a Python virtual environment
#
# Purpose: This script installs Ansible in a Python virtual environment.
#          It also installs the required packages if they are not already installed.
#          The script can also deactivate the virtual environment if needed.
#
# Usage: bash ansible_venv_install.sh [-l|--location <venv_location>]
#                                     [-v|--version <ansible_version>] [-d|--deactivate] [-h|--help]
#
# Change Log:
# 2025-01-01 - Initial version
# 2025-01-02 - Added support for configuration file
# 2025-01-03 - Added support for deactivating the virtual environment
# 2025-01-04 - Added support for exporting Python venv path
# 2025-01-05 - Added support for exporting local environment variable
#
############################################

#### Dynamic Variables ####
default_venv_location="/app/python/venv" #default venv location
default_ansible_version="" #default Ansible version. BLANK=latest
deactivate_venv=false #enable to deactivate Python venv
python_venv_export_file="/tmp/.ANSIBLE_VENV_PATH" #store the Python venv path value


#### STATIC VARIABLES ####
# OS packages required for Ansible installation
debian_packages=("sshpass" "python3" "python3-venv" "python3-pip")
centos_packages=("sshpass" "python3" "python3-pip")

# Determine the script's directory and base name
script_source="${BASH_SOURCE[0]}"
while [ -h "$script_source" ]; do # resolve $script_source until the file is no longer a symlink
  script_dir="$(cd -P "$(dirname "$script_source")" && pwd)"
  script_source="$(readlink "$script_source")"
  [[ $script_source != /* ]] && script_source="$script_dir/$script_source" # if $script_source was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
script_dir="$(cd -P "$(dirname "$script_source")" && pwd)"
script_base_name="$(basename "$script_source" .sh)"
config_file="$script_dir/${script_base_name}.cfg"


#### Functions ####
# Check if Python, python3-venv, and pip are installed
check_required_packages() {
  # Check if required packages are already installed
  if ! command -v python3 &>/dev/null || ! dpkg -l | grep -q "python3-venv" || ! command -v pip3 &>/dev/null; then
    echo "Attempting to install required packages..."

    # Check if the OS is Linux
    if [ "$(uname)" != "Linux" ]; then
        echo "ERROR - This script is intended for Linux only. Exiting."
        exit 100
    fi
    
    # Install required packages
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y "${debian_packages[@]}"
    elif command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum install -y "${centos_packages[@]}"
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y "${centos_packages[@]}"
    else
        echo "ERROR - Unsupported package manager. Please install the required packages manually."
        echo "Debian packages: ${debian_packages[@]}"
        echo "CentOS packages: ${centos_packages[@]}"
        exit 101
    fi

    echo "Installation completed successfully."
  else
    echo "System has passed prerequisite tests."
  fi
}

# Create a Python virtual environment and directory if it doesn't exist
create_venv() {
  local venv_location="$1"
  # Check if the directory exists; if not, create it
  if [ ! -d "$venv_location" ]; then
    mkdir -p "$venv_location"
    echo "Created PY venv dir at $venv_location"
  fi
  python3 -m venv "$venv_location"
}

# Activate the virtual environment
activate_venv() {
  local venv_location="$1"
  
  source "$venv_location/bin/activate"
  local venv_activated="$?"

  if [ "$venv_activated" -eq 0 ]; then
    echo "Activated PY venv at $venv_location"
  else
    echo "ERROR - PY venv $venv_location could not be activated"
    exit 102
  fi
}

# Compare floating-numbers in Bash
compare_float_versions() {
  local version1="$1"
  local version2="$2"

  # Put versions in order (latest to oldest)
  local sorted_versions=($(printf "%s\n%s\n" "$version1" "$version2" | sort -Vr))

  # Find the postion of each version within array
  pos_version1=$(echo "${sorted_versions[@]}" | grep -n "$version1" | cut -d: -f1)
  pos_version2=$(echo "${sorted_versions[@]}" | grep -n "$version2" | cut -d: -f1)
}

# Install Ansible using pip within the virtual environment
install_ansible() {
  local venv_location="$1"
  local ansible_version="$2"
  
  # Upgrade pip
  echo "Upgrading pip to latest version ..."
  pip install pip --upgrade --require-virtualenv
  
  if command -v ansible &>/dev/null; then
    local ansible_installed_version=$(pip list | grep ansible | awk 'NR==1{print $2}')
    if [[ "$ansible_version" == "$ansible_installed_version" ]]; then
      echo "Ansible version already installed"
    else
      compare_float_versions $ansible_version $ansible_installed_version
      local pos_ansible_version=$pos_version1
      local pos_ansible_installed_version=$pos_version2

      if [[ "$pos_ansible_version" -lt "$pos_ansible_installed_version" ]]; then
        echo "ERROR - Downgrading Ansible is not possible.  Install Ansible into different Python vENV."
        exit 103
      fi
      if [[ "$pos_ansible_version" -gt "$pos_ansible_installed_version" ]]; then
        echo "Upgrading Ansible installation to version: $ansible_version"
        pip install "ansible==$ansible_version" --upgrade --require-virtualenv
      fi
    fi
  else
    echo "Installing Ansible into Python vENV: ${venv_location}"
    if [ -z "$ansible_version" ]; then
      pip install ansible --require-virtualenv
    else
      pip install "ansible==$ansible_version" --require-virtualenv
    fi
  fi
}

# Deactivate the virtual environment
deactivate_py_venv() {
  if command -v deactivate &>/dev/null; then
    deactivate
    echo "Virtual environment has been deactivated."
  else
    echo "No virtual environment to deactivate."
  fi
}

# Install the 'sshpass' Linux package

# Show help and usage information
show_help() {
  echo "Usage: $0 [-l|--location <venv_location>] [-v|--version <ansible_version>] [-d|--deactivate] [-h|--help]"
  echo "  -c, --config_file Specify the full path to configuration file with flags"
  echo "  -l, --location    Specify the location for the virtual environment (optional)."
  echo "  -v, --version     Specify the Ansible version to install (optional)."
  echo "  -d, --deactivate  Deactivate the virtual environment (no installation if provided)."
  echo "  -h, --help        Show this help message and exit."
  echo "Notes:"
  echo "  Any flags provided via command line take presedence over config file."
  echo "  config_file options:"
  echo "  '-c' => config_file=<full path to config file>"
  echo "  '-l' => venv_location=<full path to Python venv directory>"
  echo "  '-v' => ansible_version=<Ansible version>"
  echo "  '-d' => deactivate_venv=true"
  exit 200
}

# Check if a flag is set, and if not, show help and exit
check_flag() {
  local flag_value="$1"
  local flag_name="$2"
  if [ -z "$flag_value" ]; then
    echo "Error - $flag_name flag is required."
    show_help
    exit 104
  fi
}

# Process command-line arguments
process_args() {
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      -c|--config_file)
        config_file="$2"
        shift 2
        ;;
      -l|--location)
        venv_location="$2"
        shift 2
        ;;
      -v|--version)
        ansible_version="$2"
        shift 2
        ;;
      -d|--deactivate)
        deactivate_venv=true
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        # Unknown option
        echo "Unknown option: $key"
        show_help
        exit 105
        ;;
    esac
  done
}


#### Main ####
# Source configuration file if it exists
if [ -s "$config_file" ]; then
  echo "Found configuration file $config_file"
  source "$config_file"
else
    echo "ERROR - no config_file found"
fi

# Process command-line arguments
process_args "$@"

# Check if the -d flag is provided
if [ "$deactivate_venv" = true ]; then
  # Deactivate the virtual environment if it exists
  echo "Deactiving Python venv ..."
  deactivate_py_venv
  exit 0
fi

# Check if Python, python3-venv, and pip are installed
echo "Verifying prerequisite packages are installed ..."
check_required_packages

# Use the specified location if provided, or use the default location
if [ -z "$venv_location" ]; then
  venv_location="$default_venv_location"
fi

# Create a Python virtual environment at the specified location
echo "Creating Python venv at $venv_location"
create_venv "$venv_location"

# Activate the virtual environment
echo "Activating Python venv at $venv_location"
activate_venv "$venv_location"

# Install Ansible using pip within the virtual environment
echo "Installing Ansible environment ..."
install_ansible "$venv_location" "$ansible_version"

# Check if Ansible was successfully installed
if command -v ansible &>/dev/null; then
  echo "Ansible has been successfully installed in the virtual environment at $venv_location."
else
  echo "ERROR - Failed to install Ansible. Please check your Python environment and try installing it manually."
fi

# Export Python venv location for secondary scripts
echo "$venv_location" > $python_venv_export_file
echo "Exported Python venv path to be used by secondary script at $python_venv_export_file"

export ANSIBLE_VENV_PATH="$venv_location"
echo "Exported local ENV ANSIBLE_VENV_PATH=$venv_location"