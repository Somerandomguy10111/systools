#!/bin/bash

source lib/uuid_to_dev.sh

# Input parameters
part_id="dm-name-VG-lv_nvme0n1p2"

#---------------------#

fsys_dev=$(id_to_logical_name $part_id)
#SNAPSHOT_SIZE="10G"
#SNAPSHOT_NAME="ubuntu-snapshot"
THRESHOLD_SIZE=20  # Threshold for shrinking in GB

vg_name=$(dmsetup info -c --noheadings -o vg_name "$fsys_dev")
lv_name=$(dmsetup info -c --noheadings -o lv_name "$fsys_dev")
full_lv_path="/dev/$vg_name/$lv_name"

#---------------------#

#SCRIPT_PID=$$
#PARENT_PID=$PPID
#
#echo $SCRIPT_PID
#echo $PARENT_PID

# Send SIGTERM to all processes except the script and its parent
#for pid in $(ps -e -o pid --no-headers); do
#    if [ "$pid" != "$SCRIPT_PID" ] && [ "$pid" != "$PARENT_PID" ]; then
#        kill -SIGTERM "$pid" 2>/dev/null
#    fi
#done

# Wait a moment to allow processes to terminate gracefully
#sleep 5


# Temporary mount point
temp_mount="/mnt/temp-lvm"

# Create a temporary mount point
mkdir -p "$temp_mount"

# Mount the logical volume temporarily
mount "$fsys_dev" "$temp_mount"

echo "$fsys_dev"

# Get the current usage of the filesystem
current_usage=$(df --output=used -BG "$temp_mount" | tail -n 1 | tr -dc '0-9')

# Get the total size of the logical volume
total_lv_size=$(lsblk -b -d -n -o SIZE "$fsys_dev" | awk '{print int($1/1024/1024/1024)}')

# Calculate the free space (used space vs LV size)
free_space=$((total_lv_size - current_usage))

echo "Filesystem mount point: $temp_mount"
echo "Current usage of filesystem: $current_usage GB"
echo "Total size of logical volume: $total_lv_size GB"
echo "Available space for shrinking: $free_space GB"

# Check if free space is greater than the threshold
if [ "$free_space" -gt "$THRESHOLD_SIZE" ]; then
    echo "Shrinking volume by $THRESHOLD_SIZE GB"
    lvreduce --resizefs --size -${THRESHOLD_SIZE}G "$full_lv_path"
else
    echo "Not enough free space to shrink the volume"
fi



# Create an LVM snapshot
#lvcreate --size "$SNAPSHOT_SIZE" --snapshot --name "$SNAPSHOT_NAME" "$fsys_dev"

