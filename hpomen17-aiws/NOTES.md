# NOTES - manually install/configure workflow

The NOTES is intended to be a manual process to duplicate what the automation playbook will accomplish.  If you want to understand more of what the playbook is doing or more of a hand-on approach, follow this document.

## HP Specific Drivers

purpose: Install HP specific drivers for the 8a18 baseboard

Commands:
```shell
sudo apt install -y fwupd hplip htop lm-sensors
sudo fwupdmgr refresh
sudo fwupdmgr update
```

## Ubuntu Required Packages

purpose: Install Ubuntu required packages

Commands:
```shell
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential dkms linux-headers-$(uname -r) \
    software-properties-common curl wget git unzip
```

## Install Intel GPU Drivers

purpose: Install drivers and utils for Intel GPU

Commands:
```shell
sudo apt install -y mesa-utils intel-media-va-driver \
    intel-gpu-tools libvulkan1 libvulkan-dev \
    vulkan-tools libva-dev \
    vainfo clinfo ocl-icd-opencl-dev
```

### Set Intel ENV

purpose: Intel GPU required ENV to be set

Commands:
```shell
echo "export LIBVA_DRIVER_NAME=iHD" | sudo tee -a /etc/environment
echo "export VDPAU_DRIVER=va_gl" | sudo tee -a /etc/environment
```

#### Enable Vulkan Support

purpose: Enable the Vulkan support for the Intel GPU

Commands:
```shell
sudo apt install -y mesa-vulkan-drivers
```

## Install Ubuntu nVidia Drivers

purpose: Install the Ubuntu approved drivers of nVidia GPU

Commands:
```shell
sudo add-apt-repository --component restricted multiverse
sudo apt update
```

```shell
sudo apt install ubuntu-drivers-common
sudo ubuntu-drivers install nvidia:570-server-open
```

### Configure GPU Prime Settings

purpose: Configure the Intel GPU to be used for screen rendering and nVidia reserved for AI tasks

Commands:
```shell
sudo vim /etc/X11/xorg.conf.d/prime-hybrid.conf
```

Contents of /etc/X11/xorg.conf.d/prime-hybrid.conf
```shell
Section "ServerLayout"
    Identifier "layout"
    Option "AllowNVIDIAGPUScreens"
EndSection

Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
    Option "PrimaryGPU" "yes"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "PrimaryGPU" "no"
    Option "AllowExternalGpus" "false"
    Option "SLI" "Off"
    Option "BaseMosaic" "off"
EndSection
```

### Configure nVidia Prime Settings

purpose: Configure nVidia prime

Commands:
```shell
sudo vim /etc/nvidia/nvidia-pm.conf
```

Contents of /etc/nvidia/nvidia-pm.conf
```shell
# Configuration to keep the NVIDIA GPU for compute only
AutoPowerControlMode=2
```

Commands:
```shell
sudo prime-select intel
```

### Install nVidia CUDA

purpose: Install the nVidia CUDA toolkit

Commands:
```shell
sudo apt install -y nvidia-cuda-toolkit
```

#### Set CUDA ENV

purpose: Set CUDA ENV

add lines to the bottom of the ~/.bashrc
ensure these only exist once (do not create duplicate entries)

Contents to add to $HOME/.bashrc
```shell
export CUDA_DEVICE_ORDER=PCI_BUS_ID
export CUDA_VISIBLE_DEVICES=0  # Makes only the NVIDIA GPU visible to CUDA
```

## Install nvtop with Intel support

purpose: Install nvtop with support for Intel GPU and nVidia.  Have to compile nvtop from source

Commands:
```shell
sudo apt install -y libsystemd-dev libudev-dev build-essential libdrm-dev libpci-dev
```

```shell
mkdir -p $HOME/source/nvtop/ && cd $HOME/source/nvtop
git clone https://github.com/Syllo/nvtop.git
cd nvtop
```

```shell
mkdir build && cd build
cmake .. -DINTEL_SUPPORT=ON

make
sudo make install
```

## Activate Changes

purpose: System needs to be rebooted for changes to take effect

Commands:
```shell
sudo reboot
```

## Verify GPU Configurations

### Verify nVidia Hardware is detected

purpose: verify nVidia hardware is detected

Commands:
```shell
lspci | grep -i nvidia
```

EXPECTED OUTPUT (successful):
the below string should be within output
```
NVIDIA Corporation GA103M [GeForce RTX 3080 Ti Laptop GPU]
```

### Verify Intel GPU is handling display

purpose: verify Intel GPU is handling display

Commands:
```shell
glxinfo | grep "OpenGL renderer"
```

EXPECTED OUTPUT (successful):
the below string should be within output
```
OpenGL renderer string: Mesa Intel(R) Graphics (ADL GT2)
```

### Verify Prime-select

purpose: verify prime-select

Commands:
```shell
prime-select query
```

EXPECTED OUTPUT (successful):
this is the exact output expected
```
intel
```

### Verify nVidia-smi


purpose: verify nvidia-smi sees RTX GPU

Commands:
```shell
nvidia-smi -L
```

EXPECTED OUTPUT (successful):
the below string should be within output
```
NVIDIA GeForce RTX 3080 Ti Laptop GPU
```

### Verify CUDA toolkit

purpose: verify CUDA toolkit

Commands:
```shell
nvcc --version
```

EXPECTED OUTPUT (successful):
the below string should be within output
```
nvcc: NVIDIA (R) Cuda compiler driver
```