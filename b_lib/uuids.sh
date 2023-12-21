#!/bin/bash
## Assigns random uuids to all partitions on specified disk

source ../devices.sh


echo -e "### Random UUID assignment: uuid.sh: LAUNCH"
echo "-> Input device: Disk $disk0"

partitions=$(lsblk -lno NAME,TYPE "$disk0" | grep 'part' | awk '{print $1}')

for part in $partitions; do
    dev="/dev/$part"
    fstype=$(lsblk -lno FSTYPE "$dev")

    echo "-> Processing $dev with filesystem type: $fstype"

    if [ "$fstype" == "ext4" ]; then
        new_uuid=$(uuidgen)
        sudo e2fsck -f "$dev"
        sudo tune2fs -U "$new_uuid" "$dev"
        echo "-> Assigned new UUID $new_uuid to $dev"

    elif [ "$fstype" == "vfat" ]; then
        # For FAT32 (vfat), use mlabel
        sudo mlabel -s -n :: -i "$dev"
        uuid=$(sudo blkid -s UUID -o value "$dev")
        echo "->Assigned new UUID $uuid to $dev"
    else
        echo "->Unsupported filesystem type $fstype on $dev"
    fi
done

echo -e "### Random UUID assignment: uuid.sh: OK"
echo ""

