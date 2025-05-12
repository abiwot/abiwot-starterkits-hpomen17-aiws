#!/bin/bash

############################################
# Script to check NVIDIA drivers and CUDA installation
#
# Purpose: This script checks if NVIDIA drivers and CUDA are properly installed.
#
# Usage: bash check_nvidia.sh
#
# Change Log:
# 2025-01-04 - Initial version
#
############################################

echo "Checking NVIDIA drivers and CUDA installation..."
echo "-----------------------------------------------"

# Check if nvidia-smi is available
if command -v nvidia-smi &>/dev/null; then
    echo "NVIDIA drivers are installed."
    echo "NVIDIA driver information:"
    nvidia-smi
else
    echo "ERROR: NVIDIA drivers are not installed or not functioning properly."
    exit 1
fi

echo ""
echo "-----------------------------------------------"

# Check if CUDA is available
if command -v nvcc &>/dev/null; then
    echo "CUDA is installed."
    echo "CUDA version:"
    nvcc --version
else
    echo "ERROR: CUDA is not installed or not in PATH."
    exit 2
fi

echo ""
echo "-----------------------------------------------"

# Check CUDA samples if available
cuda_samples_path="/usr/local/cuda/samples"
if [ -d "$cuda_samples_path" ]; then
    echo "CUDA samples are available at $cuda_samples_path"
    
    # Try to compile and run deviceQuery
    if [ -d "$cuda_samples_path/1_Utilities/deviceQuery" ]; then
        echo "Compiling and running deviceQuery..."
        cd "$cuda_samples_path/1_Utilities/deviceQuery" || exit 3
        make &>/dev/null
        if [ -f "./deviceQuery" ]; then
            ./deviceQuery
        else
            echo "Failed to compile deviceQuery."
        fi
    else
        echo "deviceQuery sample not found."
    fi
else
    echo "CUDA samples not found at $cuda_samples_path"
fi

echo ""
echo "-----------------------------------------------"
echo "NVIDIA and CUDA environment variables:"
echo "PATH: $PATH"
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH"

echo ""
echo "-----------------------------------------------"
echo "Check complete."