#!/bin/bash

## Creates an LVM copy of a "main disk" on a "target disk"

# Input variables
# Look up using: ls -l /dev/disk/by-id
main_unique_id="usb-SSK_SD30_0_1TB_ABCDEFA75101-0:0"
target_unique_id="nvme-nvme.c0a9-323332324536444337344542-435431303030503353534438-00000001"

#---------------------# 
# Internal parameters

vg_name="VG"
lv_name_prefix="lv"


source lib/name_resolution.sh
#main_disk="nvme0n1"
#target_disk="nvme1n1"
main_disk=$(id_to_logical_name $main_unique_id)
target_disk=$(id_to_logical_name $target_unique_id)

#---------------------#

# Unmount the target disk if it is mounted
echo "-> Unmounting target disk $target_disk"
sudo umount "$target_disk" 2> /dev/null || true

#Wipe the target
#echo "-> Wiping partition table of target disk $target_disk"
#sudo dd if=/dev/zero of="$" bs=512 count=1

esp=$(lsblk -lno NAME,TYPE,PARTTYPE "$main_disk" | grep -E 'part.*c12a7328-f81f-11d2-ba4b-00a0c93ec93b' | awk '{print $1}')
if [ ! -z "$esp" ]; then
    esp_size=$(sudo blockdev --getsize64 /dev/"$esp")
    echo "-> Creating and cloning ESP of size $esp_size bytes"
    sudo parted "$target_disk" mkpart primary fat32 1MiB $((esp_size / 1024 / 1024 + 1))MiB
    sudo bash -c "pv < /dev/$esp > /dev/$target_disk"
fi


## Make Volume group on target
#echo "-> Creating volume group $vg_name on target disk $target_disk"
#sudo pvcreate "$target_disk"
#sudo vgcreate $vg_name "$target_disk"
#
#
## Create create LV copies of partition on target
#partitions=$(lsblk -lno NAME,TYPE "$main_disk" | grep 'part' | awk '{print $1}')
#
#for partition in $partitions; do
#    # Get the size of the partition
#    size=$(sudo blockdev --getsize64 /dev/"$partition")
#    echo " "
#    echo "-> Recognized partition $partition of size $size bytes on $main_disk"
#
#    # Create a corresponding logical volume of the same size
#    lv_name="${lv_name_prefix}_$(basename "$partition")"
#    echo "-- Creating LMV partition mirroring $partition with name $lv_name on $vg_name"
#    sudo lvcreate -L "${size}"b -n "$lv_name" "$vg_name"
#
#    # Clone the partition to the new logical volume
#    echo "-- Cloning partition $partition to logical volume $lv_name"
#    sudo bash -c "pv < /dev/$partition > /dev/$vg_name/$lv_name"
#done
#
#echo "-> Activating LVM volumes"
#sudo vgchange -ay
#
#echo "### Disks after process completion ###"
#sudo lsblk | grep -v loop

echo 'done'
