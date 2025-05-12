# NVIDIA Drivers Role

This Ansible role installs and configures NVIDIA drivers, CUDA toolkit, and related components on Ubuntu 24.04 systems with hybrid Intel/NVIDIA graphics.

## Overview

This role is designed for HP laptops with hybrid Intel/NVIDIA graphics, specifically targeting the HP Omen 17 with Intel integrated graphics and NVIDIA GeForce RTX 3080 Ti Laptop GPU. It configures the system to use Intel graphics for display rendering while reserving the NVIDIA GPU for compute tasks like AI/ML workloads.

## Features

- Installs required Ubuntu packages and HP-specific drivers
- Configures Intel GPU drivers and environment variables
- Installs NVIDIA drivers using ubuntu-drivers
- Configures GPU Prime settings for hybrid graphics
- Sets up NVIDIA Prime for compute-only mode
- Installs NVIDIA CUDA toolkit
- Configures CUDA environment variables
- Installs nvtop with Intel support (compiled from source)
- Includes verification tasks to ensure proper installation

## Requirements

- Ubuntu 24.04 Desktop
- Sudo privileges
- Internet connection
- HP laptop with hybrid Intel/NVIDIA graphics

## Role Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `nvidia_cuda_version` | "12-8" | CUDA version to install |
| `apt_cache_valid_time` | 3600 | APT cache validity time in seconds |
| `nvidia_prime_mode` | "intel" | Prime mode (intel, nvidia, or on-demand) |
| `cuda_device_order` | "PCI_BUS_ID" | CUDA device order setting |
| `cuda_visible_devices` | "0" | CUDA visible devices setting |
| `nvtop_git_repo` | "https://github.com/Syllo/nvtop.git" | Git repository for nvtop |
| `nvtop_source_dir` | "{{ ansible_env.HOME }}/source/nvtop" | Directory for nvtop source code |
| `nvtop_intel_support` | true | Whether to enable Intel support in nvtop |

## Dependencies

None.

## Example Playbook

```yaml
- hosts: localhost
  become: true
  roles:
    - role: nvidia_drivers
      nvidia_prime_mode: "intel"
```

## Verification

After installation, the role performs several verification tasks:

1. Checks if NVIDIA hardware is detected
2. Verifies Intel GPU is handling display
3. Confirms prime-select is set to intel
4. Checks if nvidia-smi can see the NVIDIA GPU
5. Verifies CUDA toolkit installation

You can also manually run the verification script:

```bash
bash/check_nvidia.sh
```

## Notes

- A system reboot is required after installation for all changes to take effect
- The role is designed to configure the system for AI/ML workloads, using Intel GPU for display and NVIDIA GPU for compute
- The role follows the configuration steps outlined in the project's NOTES.md file