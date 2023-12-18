#!/bin/bash

## Creates an LVM copy of a "main disk" on a "target disk"

# Input variables for boot and filesystem partitions
target_disk='/dev/sdX'
boot_partition="/dev/sda1"
fsys_partition="/dev/sda2"

vg_name="VG"
lv_name_prefix="lv"

#---------------------#
boot_size=$(sudo blockdev --getsize64 "$boot_partition")
new_boot_dev_name="${target_disk}1"

echo "-> Cloning boot $boot_partition to $new_boot_dev_name of size $boot_size bytes"
#sudo parted "$target_disk" mkpart primary fat32 1MiB $((boot_size / 1024 / 1024 + 1))MiB
#sudo bash -c "pv < $boot_partition > $new_boot_dev_name"

new_lvm_part_name="${target_disk}2"
echo "-> Creating new partition for LVM on $new_lvm_part_name"
#sudo parted "$target_disk" mkpart primary ext4 $((boot_size / 1024 / 1024 + 1))MiB 100%

echo "-> Creating Physical Volume on $new_lvm_part_name"
#sudo pvcreate "$new_lvm_part_name"
echo "-> Creating Volume Group $vg_name"
#sudo vgcreate "$vg_name" "$new_lvm_part_name"

new_lv_dev_name="/dev/$vg_name/${lv_name_prefix}_$(basename "$fsys_partition")"
fsys_size=$(sudo blockdev --getsize64 "$fsys_partition")

echo "-> Creating LVM for filesystem partition $fsys_partition on $new_lv_dev_name of size $fsys_size bytes"
#sudo lvcreate -L "${fsys_size}"b -n "${lv_name_prefix}_$(basename "$fsys_partition")" "$vg_name"
#sudo bash -c "pv < $fsys_partition > $new_lv_dev_name"
