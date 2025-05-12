# Ubuntu 24.04 Development Environment Setup

This project automates the initial configuration of a laptop environment running Ubuntu 24.04 desktop. It's designed primarily for setting up a development environment capable of running LLMs locally.

## Overview

The project follows this approach:
1. Install Ansible locally within a Python virtual environment (using `ansible_venv_install.sh`)
2. Run multiple Ansible playbooks and roles to:
   - Install NVIDIA GPU drivers, CUDA toolkit, and CUDA drivers
   - Install basic packages (net-tools, vim, wget, htop, curl, dnsutils, ssh-server)
   - Add SSH keys to authorized keys
   - Install development packages (gcc, g++, make, cmake, go)
   - Configure vim with custom settings

## Prerequisites

- Ubuntu 24.04 Desktop
- Internet connection
- Sudo privileges

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/abiwot/abiwot-starterkits-hpomen17-aiws.git
   cd abiwot-starterkits-phomen17-aiws/hpomen17-aiws
   ```

2. Install Ansible in a Python virtual environment:
   ```
   bash bash/ansible_venv_install.sh
   ```

3. Run the main playbook:
   ```
   source /app/python/venv/bin/activate  # Or your custom venv path
   ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml
   ```

## Components

### Ansible Virtual Environment Setup

The `ansible_venv_install.sh` script installs Ansible in a Python virtual environment. It:
- Checks for and installs required packages
- Creates and activates a Python virtual environment
- Installs Ansible within the virtual environment

### Ansible Playbooks and Roles

The project includes several roles:
- **nvidia_drivers**: Installs NVIDIA GPU drivers, CUDA toolkit, and CUDA drivers
- **basic_packages**: Installs essential system utilities
- **ssh_keys**: Configures SSH keys
- **dev_packages**: Installs development tools and applications
- **vim_config**: Sets up vim with custom configuration

## Usage

To run specific roles only, use tags:

```
ansible-playbook playbooks/main.yaml -i inventory/hosts.yaml --tags "nvidia,basic_packages"
```

Available tags:
- nvidia
- basic_packages
- ssh_keys
- dev_packages
- vim_config

## License

This project is proprietary and confidential.

## Project Status

Active development.
