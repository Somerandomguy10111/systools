#!/bin/bash

# look the id through ls -l /dev/disk/by-id
id_to_name() {
    identifier=$1
    logical_name=$(readlink -f /dev/disk/by-id/"$identifier")
    echo "$logical_name"
}

# Linux unlock gnome keyring
function unlock-keyring ()
{
    export $(echo -n $1 | gnome-keyring-daemon --replace --unlock)
}

set +o history

USB_ID="usb-USB_SanDisk_3.2Gen1_01016457574929dacf3edfba5a9b31fea6decbbf58b1759d540e5367e4c4eff5362e00000000000000000000288dd90800003400835581074eaeb250-0:0-part2"
HOME_DIR="/home/daniel"
NAME=".protected"
MOUNT_POINT="$HOME_DIR/$NAME"

echo "Enter pwd:"
read -s pwd
passcode=$(echo -n "$pwd" | sha256sum | cut -d ' ' -f 1)
unset pwd


cleanup() {
    echo "-> Performing cleanup tasks..."
    set -o history # turn it back on
    unset pwd passcode
    echo done
}
trap cleanup EXIT


#----------------------------------------------------------------------------

echo "-> Unlocking keyring"
unlock-keyring $passcode


USB_DEV=$(id_to_name $USB_ID)
echo "-> Recognized USB_DEV: $USB_DEV"

if [ ! -d "$MOUNT_POINT" ]; then
    mkdir -p "$MOUNT_POINT"
fi

if [ ! -b "$USB_DEV" ]; then
    echo "USB device not found. Exiting."
    exit 1
fi

# Mount the device
sudo umount "/dev/mapper/$NAME"
sudo cryptsetup luksClose $NAME

echo "-> Opening encrypted drive $NAME"

echo -n "$passcode" | sudo cryptsetup luksOpen $USB_DEV $NAME
unset passcode

sudo mount "/dev/mapper/$NAME" "$MOUNT_POINT"

# Change ownership and permissions
sudo chown -R daniel:daniel $MOUNT_POINT
sudo chmod 755 $MOUNT_POINT

echo "-> Mounted encrypted drive at: $MOUNT_POINT"

# Create an array of directories in the mount point
dir_list=($(find $MOUNT_POINT -maxdepth 1 -type d ! -name "lost+found"))

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

