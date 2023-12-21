#!/bin/bash

## Creates an LVM copy of a "main disk" on a "target disk"

# Input variables for boot and filesystem partitions
target_disk='/dev/nvme0n1'
boot_partition="/dev/sdb1"
fsys_partition="/dev/sdb2"

vg_name="VG"
lv_name_prefix="lv"

#---------------------#

last_partition_end=$(sudo fdisk -l "$target_disk" | grep "^$target_disk" | awk '{print $3}' | sort -nr | head -n 1)
last_partition_end_mib=$(( (last_partition_end + 1) * 512 / 1024 / 1024 ))
echo "-> Recognized last partition end at $last_partition_end_mib MiB"

new_partition_start=$((last_partition_end_mib + 1))
echo "-> Creating new ext4 partition on $target_disk from $new_partition_start to end of disk"
sudo parted "$target_disk" -- mkpart primary ext4 "${new_partition_start}MiB" 100%
sleep 1

# Get the device name of the partition with the last end point on the target disk
new_lvm_part_name=$(sudo fdisk -l "$target_disk" | grep "^$target_disk" | sort -k 3 -n | tail -n 1 | awk '{print $1}')
echo "-> Recognized last partition on $target_disk: $new_lvm_part_name"

echo "-> Creating Physical Volume on $new_lvm_part_name"
sudo pvcreate "$new_lvm_part_name"

echo "-> Creating Volume Group $vg_name"
sudo vgcreate "$vg_name" "$new_lvm_part_name"

new_lv_dev_name="/dev/$vg_name/${lv_name_prefix}_$(basename "$fsys_partition")"
fsys_size=$(sudo blockdev --getsize64 "$fsys_partition")

echo "-> Creating LVM for filesystem partition $fsys_partition on $new_lv_dev_name of size $fsys_size bytes"
sudo lvcreate -L "${fsys_size}"b -n "${lv_name_prefix}_$(basename "$fsys_partition")" "$vg_name"
sudo bash -c "pv < $fsys_partition > $new_lv_dev_name"
