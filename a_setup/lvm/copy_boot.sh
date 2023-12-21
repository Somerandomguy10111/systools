# Input variables for boot and filesystem partitions
target_disk='/dev/nvme0n1'
boot_partition="/dev/sdb1"
#fsys_partition="/dev/sdb2"

#vg_name="VG"
#lv_name_prefix="lv"

#---------------------#
new_boot_dev_name="${target_disk}p1"

sudo parted $target_disk mklabel gpt

# Get the start and end of the original boot partition in MiB
boot_partition_size=$(sudo parted "$boot_partition" -ms unit MiB print | awk -F: '$1 == "1" {print ($3 - $2)}')
echo "-> Cloning boot $boot_partition to $new_boot_dev_name of size $boot_partition_size bytes"

# Shift the start to 1MiB and adjust the end accordingly
new_boot_partition_start=1
new_boot_partition_end=$(echo "$new_boot_partition_start + $boot_partition_size" | bc)
echo "New Start: $new_boot_partition_start MiB, New End: $new_boot_partition_end MiB"

# Create the new partition on the target disk
sudo parted "$target_disk" mkpart primary fat32 "${new_boot_partition_start}MiB" "${new_boot_partition_end}MiB"
sudo bash -c "pv < $boot_partition > $new_boot_dev_name"