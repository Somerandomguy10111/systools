target_disk=$1
boot_partition=$2

#---------------------#


boot_partition_size=$(sudo parted "$boot_partition" -ms unit MiB print | awk -F: '$1 == "1" {print ($3 - $2)}')
new_boot_partition_start=1
new_boot_partition_end=$(echo "$new_boot_partition_start + $boot_partition_size" | bc)
echo "-> Recognized originall boot partition $boot_partition of size $boot_partition_size MiB"

# Create the new partition on the target disk
sudo parted "$target_disk" mkpart primary fat32 "${new_boot_partition_start}MiB" "${new_boot_partition_end}MiB"
sleep 2
new_boot_dev_name=$(sudo fdisk -l "$target_disk" | grep "^$target_disk" | sort -k 2 -n | head -n 1 | awk '{print $1}')
echo "-> Created new boot partition $new_boot_dev_name of size $boot_partition_size MiB on target disk $target_disk"

#sudo bash -c "pv < $boot_partition > $new_boot_dev_name"
echo "-> Cloned $boot_partition to $new_boot_dev_name"
echo "done"
