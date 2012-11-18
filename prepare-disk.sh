#!/bin/bash

# Looking for drives
device_info=$( parted -lm | grep -E "/dev/[[:alpha:]]{3}:" )
device=$( echo $device_info | cut -d ':' -f 1 )
device_size=$( echo $device_info | cut -d ':' -f 2 )

# Create label
parted mklabel $device msdos

# Set default units
parted $device unit MiB

# Create boot partition
part_start=0
part_end=256
parted $device mkpart primary ext2 boot $part_start $part_end
device_boot=${device}1

# Create swap partition
part_start=$part_end
part_end=$(( part_start + 4096 ))
parted $device mkpart primary linux-swap swap $part_start $part_end
device_swap=${device}2

# Create root partition
part_start=$part_end
part_end=$device_size
parted $device mkpart primary ext2 root $part_start $part_end
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


