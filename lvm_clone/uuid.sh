#!/bin/bash
## Assigns random uuids and

#/dev/nvme0n1
disk_id="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001"

source ../lib/uuid_to_dev.sh
disk=$(id_to_logical_name $disk_id)
partitions=$(lsblk -lno NAME,TYPE "$disk" | grep 'part' | awk '{print $1}')

for part in $partitions; do
    # Get the filesystem type
    dev="/dev/$part"
    fstype=$(lsblk -lno FSTYPE "$dev")

    echo "-> Processing $dev with filesystem type: $fstype"

    if [ "$fstype" == "ext4" ]; then
        # For ext4, use tune2fs to change UUID
        new_uuid=$(uuidgen)
        sudo e2fsck -f "$dev"
        sudo tune2fs -U "$new_uuid" "$dev"
        echo "->Assigned new UUID $new_uuid to $dev"

    elif [ "$fstype" == "vfat" ]; then
        # For FAT32 (vfat), use mlabel
        sudo mlabel -s -n :: -i "$dev"
        uuid=$(sudo blkid -s UUID -o value "$dev")
        echo "->Assigned new UUID $uuid to $dev"
    else
        echo "->Unsupported filesystem type $fstype on $dev"
    fi
done

echo "done"


