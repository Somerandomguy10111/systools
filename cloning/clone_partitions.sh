#!/bin/bash
source ../devices.sh

target_disk=$disk1
boot_partition=$boot0
fsys_partition=$fsys0

read -p "-> Attempted cloning of boot partition $boot_partition and fsys partition $fsys_partition onto $target_disk. Proceed (y/n)?" confirmation
if [ "$confirmation" != "y" ]; then
    echo "Operation aborted."
    exit 1
fi

#---------------------#

# Clone boot_partition
boot_partition_size=$(sudo parted "$boot_partition" -ms unit MiB print | awk -F: '$1 == "1" {print ($3 - $2)}')
new_boot_partition_start=1
new_boot_partition_end=$(echo "$new_boot_partition_start + $boot_partition_size" | bc)
echo "-> Recognized original boot partition $boot_partition of size $boot_partition_size MiB"

# Create the new boot partition on the target disk
sudo parted "$target_disk" mkpart primary fat32 "${new_boot_partition_start}MiB" "${new_boot_partition_end}MiB"
sleep 2
new_boot_dev_name=$(sudo fdisk -l "$target_disk" | grep "^$target_disk" | sort -k 2 -n | head -n 1 | awk '{print $1}')
echo "-> Created new boot partition $new_boot_dev_name of size $boot_partition_size MiB on target disk $target_disk"

# Clone boot_partition to new_boot_dev_name
# Uncomment the following line to perform the actual cloning
# sudo bash -c "pv < $boot_partition > $new_boot_dev_name"
echo "-> Cloned $boot_partition to $new_boot_dev_name"

# Clone fsys_partition
fsys_partition_size=$(sudo parted "$fsys_partition" -ms unit MiB print | awk -F: '$1 == "1" {print ($3 - $2)}')
new_fsys_partition_start=$new_boot_partition_end
new_fsys_partition_end=$(echo "$new_fsys_partition_start + $fsys_partition_size" | bc)
echo "-> Recognized original fsys partition $fsys_partition of size $fsys_partition_size MiB"

# Create the new fsys partition on the target disk
sudo parted "$target_disk" mkpart primary ext4 "${new_fsys_partition_start}MiB" "${new_fsys_partition_end}MiB"
sleep 2
new_fsys_dev_name=$(sudo fdisk -l "$target_disk" | grep "^$target_disk" | sort -k 2 -n | tail -n 1 | awk '{print $1}')
echo "-> Created new fsys partition $new_fsys_dev_name of size $fsys_partition_size MiB on target disk $target_disk"

# Clone fsys_partition to new_fsys_dev_name
# Uncomment the following line to perform the actual cloning
sudo bash -c "pv < $fsys_partition > $new_fsys_dev_name"
echo "-> Cloned $fsys_partition to $new_fsys_dev_name"

echo "done"

