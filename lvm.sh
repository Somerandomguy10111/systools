## Creates an LVM copy of a physical disk on a target disk

# Input variables

main_disk="nvme0n1"
target_disk="nvme1n1"

#---------------------# 
# Internal parameters

vg_name="VG"
mnt_name="my_lv"
lv_name_prefix="lv"


#---------------------#

#Wipe the target
sudo bash -c "pv < /dev/zero > /dev/$target_disk"


# Make Volume group on target
sudo pvcreate /dev/$target_disk
sudo vgcreate $vg_name /dev/$target_disk


# Create create LV copies of partition on target
partitions=$(lsblk -lno NAME,TYPE /dev/$main_disk | grep 'part' | awk '{print $1}')
echo $partitions
for partition in $partitions; do
    # Get the size of the partition
    size=$(sudo blockdev --getsize64 /dev/$partition)
    echo "Recognized partitino $partition of size $size bytes"

     #Generate a unique LV name for each partition
    lv_name="${lv_name_prefix}_$(basename $partition)"

    # Create a corresponding logical volume of the same size
    echo 'Creating LVM copy of parition with name $lv_name'
    sudo lvcreate -L ${size}b -n $lv_name $vg_name

    # Clone the partition to the new logical volume
    sudo bash -c "pv < /dev/$partition > /dev/$vg_name/$lv_name"
done
