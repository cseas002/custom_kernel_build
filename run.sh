#!/bin/bash

# check if a file argument (the custom menu governor) was provided
if [ -z "$2" ]; then
  echo "Usage: $0 <menu governor> <linux kernel version (uname -r)>"
  echo "example: $0 menu.c linux-5.15.86"
  echo "find the version in https://cdn.kernel.org/pub/linux/kernel/<number>.x/"
  exit 1
fi

# check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: file '$1' not found"
  exit 1
fi


## Allocate extra space



# Building a new kernel image may take a few GBs of storage space. If you are in a situation where an existing experiment needs more space, you can use a cloudlab provided script to a create a new filesystem using the remaining space on the system disk:

current_dir=$(pwd)

sudo mkdir /mydata
sudo /usr/local/etc/emulab/mkextrafs.pl /mydata
sudo chmod a+rwx /mydata

## Install build tools

sudo apt -y update
sudo apt-get install bison

printf "\n" | sudo apt-get -y install build-essential linux-source bc kmod cpio flex libncurses5-dev libelf-dev libssl-dev 

## Obtain kernel source

cd /mydata
# wget https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.15.18.tar.xz
#    OR
# wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.4.139.tar.xz

# Use grep to extract the number
VERSION=$(echo "$2" | grep -oP '(?<=linux-)\d+')


wget https://cdn.kernel.org/pub/linux/kernel/v${VERSION}.x/${2}.tar.xz

# tar -xf linux-4.15.18.tar.xz
# cd linux-4.15.18
#    OR 
tar -xf ${2}.tar.xz
cd ${2}


## Configure kernel

# You can use an existing .config file a base configuration file

# CHANGE THIS BASED ON THE CONFIG FILE. e.g. cp /boot/config-5.15.0-86-generic .config
cp /boot/config* .config

# Edit .config to set the following parameters.

# To add a suffix to your kernel version name:

# CONFIG_LOCALVERSION="-mykernel"

sed -i 's/^CONFIG_LOCALVERSION=.*/CONFIG_LOCALVERSION="-mykernel"/g' .config
sed -i 's/^CONFIG_SYSTEM_TRUSTED_KEYS=.*/CONFIG_SYSTEM_TRUSTED_KEYS=""/g' .config
sed -i 's/CONFIG_DEBUG_INFO_BTF.*/# CONFIG_DEBUG_INFO_BTF is not set/' .config

# To disable trusted keys:

# CONFIG_SYSTEM_TRUSTED_KEYS=""


# copy the file to the destination folder, overwriting any existing file
cp -f "${current_dir}/$1" /mydata/${2}/drivers/cpuidle/governors/menu.c

# Finally create the configuration:

for i in {1..5}
do
printf "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n" >> inputtt.txt # for make input
done

make oldconfig < inputtt.txt
rm inputtt.txt

## Build kernel

# For a parallel build, pass the -j flag as follows. This runs it with all the threads: 
make -j$(nproc)

## Install kernel

sudo make modules_install
sudo make install

## Update grub config

sudo update-grub
# sudo reboot

## Remote boot

# After building and installing the kernel, you can reboot and use the cloudlab console to access the server console and select the kernel image to boot. The option for booting your kernel image may be available under 'Ubuntu Advanced Options'. 

# After booting the new kernel, you can validate that the new kernel is loaded by inspecting the kernel version matches the suffix you provided:

# uname -a 


## Save image

# Building a new kernel takes significant amount of time. After you build a kernel, consider whether to save it as a disk image that you can boot from or load into your experiment:

# https://docs.cloudlab.us/advanced-storage.html

## References

# https://www.cyberciti.biz/tips/compiling-linux-kernel-26.html