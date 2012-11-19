#!/bin/bash

# Looking for drives
device_info=$( parted -lm | grep -E "/dev/[[:alpha:]]+:" )
device=$( echo $device_info | cut -d ':' -f 1 )
#device_size=$( echo $device_info | cut -d ':' -f 2 )

part_size_boot=256
part_size_swap=4096
part_size_root=-1



# Set default units
parted $device unit MiB

# Create label
parted $device mklabel msdos

# Create boot partition
part_start=0
part_end=$(( part_start + part_size_boot ))
parted --align=none $device mkpart primary ext2 $part_start $part_end
device_boot=${device}1

# Create swap partition
part_start=$part_end
part_end=$(( part_start + part_size_swap ))
parted --align=none $device mkpart primary linux-swap $part_start $part_end
device_swap=${device}2

# Create root partition
part_start=$part_end
if [ $part_size_root -ge 0 ] ; then
    part_end=$(( part_start + part_size_root ))
else
    part_end='-1s'
fi
parted --align=none $device mkpart primary ext2 $part_start $part_end
device_root=${device}3

# Set boot flag
parted $device set 1 boot on



# Make filesystem on 'boot'
mkfs.ext2 $device_boot

# Make and activate swap
mkswap $device_swap
swapon $device_swap

# Make filesystem on 'root'
mkfs.ext3 $device_root

# Mounting
mkdir /mnt/gentoo
mount $device_root /mnt/gentoo
mkdir /mnt/gentoo/boot
mount $device_boot /mnt/gentoo/boot


