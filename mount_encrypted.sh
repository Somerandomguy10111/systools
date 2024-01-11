#!/bin/bash

# look the id through ls -l /dev/disk/by-id
id_to_name() {
    identifier=$1
    logical_name=$(readlink -f /dev/disk/by-id/"$identifier")

    full_lv_path=$(get_full_lv_path "$logical_name" 2> /dev/null)
    if [ $? -eq 0 ]; then
        echo "$full_lv_path"
    else
        echo "$logical_name"
    fi
}

USB_ID="usb-USB_SanDisk_3.2Gen1_01016457574929dacf3edfba5a9b31fea6decbbf58b1759d540e5367e4c4eff5362e00000000000000000000288dd90800003400835581074eaeb250-0:0-part2"
USB_DEV=$(id_to_name $USB_ID)

echo "-> Recognized USB_DEV: $USB_DEV"

HOME_DIR="/home/daniel"
MOUNT_POINT="$HOME_DIR/protected"

# Check and create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

# Exit if USB device is not available
if [ ! -b "$USB_DEV" ]; then
    echo "USB device not found. Exiting."
    exit 1
fi

# Uncomment the following line if you need to open an encrypted volume
# sudo cryptsetup luksOpen $USB_DEV my_usb

# Mount the device
sudo mount /dev/mapper/protected $MOUNT_POINT

# Change ownership and permissions
sudo chown -R daniel:daniel $MOUNT_POINT
sudo chmod 755 $MOUNT_POINT

echo "-> Mount point: $MOUNT_POINT"

# Create an array of directories in the mount point
dir_list=($(find $MOUNT_POINT -maxdepth 1 -type d))

echo "-> Found directories $dis_list"

# Iterate through the directory list
for dir in "${dir_list[@]}"; do
        dir_name=$(basename "$dir")
        if [ ! -e "$HOME_DIR/$dir_name" ]; then
            ln -s "$dir" "$HOME_DIR/$dir_name"
            echo "Created symlink for $dir_name"
        else
            echo "Skipping $dir_name, already exists in $HOME_DIR"
        fi
done

