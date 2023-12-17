#!/bin/bash

source lib/uuid_to_dev.sh

# Input parameters
fsys_uuid="904b3d65-2ffa-44c6-89e3-1df83408051c"

#---------------------#

fsys_partition=$(id_to_logical_name "$fsys_uuid")
SNAPSHOT_SIZE="10G"
SNAPSHOT_NAME="ubuntu-snapshot"
THRESHOLD_SIZE=20  # Threshold for shrinking in GB

#---------------------#

# Send SIGTERM to all processes (safe way)
killall5 -15

# Wait a moment to allow processes to terminate gracefully
sleep 5

current_usage=$(df --output=avail -BG "$fsys_partition" | tail -n 1 | tr -dc '0-9')
total_lv_size=$(lvdisplay "$fsys_partition" --units g | grep "LV Size" | tr -dc '0-9')
free_space=$((total_lv_size - current_usage))

echo "Current usage: $current_usage GB"
echo "Total LV size: $total_lv_size GB"
echo "Free space: $free_space GB"

# Check if free space is greater than the threshold
if [ "$free_space" -gt "$THRESHOLD_SIZE" ]; then
    echo "Shrinking volume by $THRESHOLD_SIZE GB"
    # Shrink the volume
#    lvreduce --resizefs --size -${THRESHOLD_SIZE}G "$fsys_partition"
else
    echo "Not enough free space to shrink the volume"
fi


# Create an LVM snapshot
#lvcreate --size "$SNAPSHOT_SIZE" --snapshot --name "$SNAPSHOT_NAME" "$fsys_partition"

