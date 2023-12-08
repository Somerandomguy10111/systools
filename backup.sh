source ./other/uuid_to_dev.sh

# Get logical name from UUID
partition_uuid =

# Get parent disk
partition="/dev/sda1"  # Replace with your partition's logical name
disk=$(lsblk -no PKNAME $partition)
echo "Disk: $disk"


# Try to shrink UUID partition
