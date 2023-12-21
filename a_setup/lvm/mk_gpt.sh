target_disk='/dev/nvme0n1'

sudo parted $target_disk mklabel gpt
echo "-> Created new partition table on target disk $target_disk"