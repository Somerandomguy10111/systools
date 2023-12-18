#!/bin/bash

# Backup parameters - adjust as needed
SNAPSHOT_MOUNT_PATH="/mnt/snapshot"
LOCAL_BACKUP_PATH="/"
#REMOTE_BACKUP_BUCKET="gs://your-bucket-name/path"

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

# Local Backup from Snapshot
rsync -aAXv "${EXCLUDE_ARGS[@]}" "$SNAPSHOT_MOUNT_PATH" "$LOCAL_BACKUP_PATH"

# Optionally unmount and remove snapshot after run
umount "$SNAPSHOT_MOUNT_PATH"
lvremove -f "/dev/ubuntu-vg/$SNAPSHOT_NAME"
