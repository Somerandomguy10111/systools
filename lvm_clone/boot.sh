source ../lib/uuid_to_dev.sh
BOOT_ID="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001-part1"
FSYS_ID="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001-part2"

#---------------------#

BOOT_PARTITION=$(id_to_logical_name $BOOT_ID)
FSYS_PARTITION=$(id_to_logical_name $FSYS_ID)
disk=$(lsblk -no PKNAME "$BOOT_PARTITION")

#Update grub
echo "-> Mounting the root partition"
sudo mount "$FSYS_PARTITION" /mnt

# Bind necessary directories
echo "->Binding resources to mount:"
sudo mkdir -p /mnt/dev /mnt/sys /mnt/proc /mnt/boot
for name in /dev /dev/pts /proc /sys /run; do
  echo -n "$name "
  sudo mount -B $name /mnt$name; done
sudo mount "$BOOT_PARTITION" /mnt/boot

# Chroot into the mounted filesystem and update boot
echo "-> Reinstalling grub on $disk"
sudo chroot /mnt /bin/bash -c "grub-install $disk; update-grub; exit"

echo "-> Updating fstab"
sudo chroot /mnt /bin/bash -c "genfstab -U / | grep -v 'loop' > /mnt/etc/fstab"

# Unmount filesystems
echo "-> Unmounting filesystems..."
sudo umount "$BOOT_PARTITION"
sudo umount "$FSYS_PARTITION"

echo "-> GRUB update process complete. Please reboot your system."
echo "done"