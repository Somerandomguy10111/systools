## Creates an LVM copy of a physical disk on a target disk

# Input variables

# Look that up using: ls -l /dev/disk/by-id
main_unique_id="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001"
target_unique_id="nvme-nvme.c0a9-323332324536444337344542-435431303030503353534438-00000001"

#---------------------# 
# Internal parameters

vg_name="VG"
lv_name_prefix="lv"


source ./other/uuid_to_dev.sh
#main_disk="nvme0n1"
#target_disk="nvme1n1"
main_disk=$(id_to_logical_name $main_unique_id)
target_disk=$(id_to_logical_name $target_unique_id)

#---------------------#

# Unmount the target disk if it is mounted
echo "Unmounting target disk $target_disk"
sudo umount "/dev/$target_disk" 2> /dev/null || true

#Wipe the target
echo "Wiping target disk $target_disk"
sudo bash -c "pv < /dev/zero > $target_disk"


# Make Volume group on target
echo "Creating volume group $vg_name on target disk $target_disk"
sudo pvcreate "$target_disk"
sudo vgcreate $vg_name "$target_disk"


# Create create LV copies of partition on target
partitions=$(lsblk -lno NAME,TYPE "$main_disk" | grep 'part' | awk '{print $1}')
echo "$partitions"
for partition in $partitions; do
    # Get the size of the partition
    size=$(sudo blockdev --getsize64 /dev/"$partition")
    echo "Recognized partition $partition of size $size bytes"

    # Create a corresponding logical volume of the same size
    lv_name="${lv_name_prefix}_$(basename "$partition")"
    echo "Creating LVM copy of parition with name $lv_name"
    sudo lvcreate -L "${size}"b -n "$lv_name" "$vg_name"

    # Clone the partition to the new logical volume
    echo "Cloning partition $partition to logical volume $lv_name"
    sudo bash -c "pv < /dev/$partition > /dev/$vg_name/$lv_name"
done
