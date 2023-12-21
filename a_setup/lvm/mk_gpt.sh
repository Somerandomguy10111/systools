sudo parted $1 mklabel gpt
echo "-> Created new partition table on target disk $1"