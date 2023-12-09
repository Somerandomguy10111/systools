source ./other/uuid_to_dev.sh
BOOT_ID="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001-part1"
FSYS_ID="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001-part2"

BOOT_PARTITION=$(id_to_logical_name $BOOT_ID)
FSYS_PARTITION=$(id_to_logical_name $FSYS_ID)


#Update grub
echo "-> Mounting the root partition"
sudo mount "$FSYS_PARTITION" /mnt

# Bind necessary directories
echo "->Binding /dev, /sys, and /proc and /boot"
sudo mkdir dev sys proc
sudo mount --bind /dev /mnt/dev
sudo mount --bind /sys /mnt/sys
sudo mount --bind /proc /mnt/proc
sudo mount "$BOOT_PARTITION" /mnt/boot


# Chroot into the mounted filesystem
echo "-> Entering chroot environment..."
sudo chroot /mnt /bin/bash <<EOF
sudo update-grub
exit
EOF

# Inside the chroot environment
echo "-> Updating GRUB configuration..."
sudo update-grub

# Exit chroot
echo "-> Exiting chroot..."
exit

# Unmount filesystems
echo "-> Unmounting filesystems..."
sudo umount /mnt/dev
sudo umount /mnt/sys
sudo umount /mnt/proc
sudo umount /mnt/boot
sudo umount /mnt

echo "-> GRUB update process complete. Please reboot your system."