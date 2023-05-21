#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install necessary packages
sudo apt install -y build-essential bc libncurses-dev

# Download the desired kernel version from kernel.org
# Replace <version> with the desired version (e.g., 5.10.0)
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.tar.xz

# Extract the downloaded kernel tarball
tar -xf linux-5.15.tar.xz
cd linux-5.15

# Download the latest preempt-rt patch
wget https://cdn.kernel.org/pub/linux/kernel/projects/rt/5.10/older/patch-5.10.30-rt30.patch.xz

# Apply the patch
xzcat patch-5.10.30-rt30.patch.xz | patch -p1

# Configure the kernel
cp /boot/config-$(uname -r) .config
yes '' | make oldconfig

# Enable preempt-rt options
make menuconfig
# In the menuconfig interface, navigate to:
#   - General setup
#   - Preemption Model (Fully Preemptible Kernel (RT))
#   - Timer frequency (1000 HZ)

# Build the kernel
make -j$(nproc)

# Install the modules
sudo make modules_install

# Install the new kernel
sudo make install

# Update the bootloader
sudo update-initramfs -c -k <version>
sudo update-grub

echo "Preempt-RT kernel installation completed. Please reboot your system to use the new kernel."
