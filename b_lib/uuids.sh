#!/bin/bash
source ../devices.sh
set -e

echo -e "### Random UUID assignment: uuid.sh: LAUNCH"
while true; do
    read -p "-> Assigning random uuids to partitions on disk $disk0: Proceed? (y/n) " yn
    case $yn in
        [Yy]* ) break;;  # If the user enters "y" or "Y", exit the loop
        [Nn]* ) exit;;   # If the user enters "n" or "N", exit the script
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done


partitions=$(lsblk -lno NAME,TYPE $disk0 | grep 'part' | awk '{print $1}')
# Check if the partitions variable is empty
if [ -z "$partitions" ]; then
    echo "Error: No partitions found or invalid input provided. Aborting ..."
    echo -e "### Random UUID assignment: uuid.sh: FAILED"
    exit 1
fi

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

