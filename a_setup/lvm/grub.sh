
# Initialize variables
BOOT_PARTITION=$1
FSYS_PARTITION=$2
target_disk=$3

#---------------------#

echo "-> Recognized target_disk $target_disk, boot partition $BOOT_PARTITION and FSYS partition $FSYS_PARTITION"

#Update grub
echo "-> Mounting the root partition"
sudo mount "$FSYS_PARTITION" /mnt

# Bind necessary directories
echo "->Binding resources to mount:"
sudo mkdir -p /mnt/dev /mnt/sys /mnt/proc /mnt/boot
for name in /dev /dev/pts /proc /sys /run; do
  echo -n "$name "
  sudo mount -B $name /mnt$name; done
echo ""
sudo mount "$BOOT_PARTITION" /mnt/boot/efi

# Chroot into the mounted filesystem and update boot
echo "-> Reinstalling grub on $target_disk"
sudo chroot /mnt /bin/bash -c "mount -t efivarfs none /sys/firmware/efi/efivars; grub-install --no-nvram $target_disk; update-grub; exit"

echo "-> Updating fstab"
sudo chroot /mnt /bin/bash -c "genfstab -U / | grep -v 'loop' > /etc/fstab"


# Unmount filesystems
echo "-> Unmounting filesystems..."
sudo umount -l "$BOOT_PARTITION"
sudo umount -l "$FSYS_PARTITION"

echo "-> GRUB update process complete. Please reboot your system."
echo "done"
