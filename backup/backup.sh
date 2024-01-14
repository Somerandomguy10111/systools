#!/bin/bash

# Backup parameters - adjust as needed
SNAPSHOT_MOUNT_PATH="/mnt/snapshot"
BASE_BACKUP_PATH="/mnt/daniel"

#---------------------#
# Internal parameters

# Exclusion list for rsync
EXCLUDE_DIRECTORIES=(
    "/dev"
    "/mnt"
    "/proc"
    "/sys"
    "/tmp"
    "/media"
    "/lost+found"
)

# Prepare the exclude arguments for rsync
EXCLUDE_ARGS=()
for dir in "${EXCLUDE_DIRECTORIES[@]}"; do
    EXCLUDE_ARGS+=("--exclude=$dir")
done

# Find directories containing 'backup' under /mnt/daniel
readarray -t BACKUP_PATHS < <(find "$BASE_BACKUP_PATH" -type d -name '*backup*')

# Local Backup from Snapshot to each backup path
for BACKUP_PATH in "${BACKUP_PATHS[@]}"; do
    echo "Backing up to: $BACKUP_PATH"
    rsync -aAXv "${EXCLUDE_ARGS[@]}" "$SNAPSHOT_MOUNT_PATH" "$BACKUP_PATH"
done

# Optionally unmount and remove snapshot after c_run
umount "$SNAPSHOT_MOUNT_PATH"
lvremove -f "/dev/ubuntu-vg/$SNAPSHOT_NAME"
