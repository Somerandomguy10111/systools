#!/bin/bash
source ../../devices.sh
set -e


# Initialize variables
BOOT_PARTITION=$boot0
FSYS_PARTITION=$fsys0
target_disk=$disk0

#---------------------#

echo -e "### Grub re-installer: grub.sh: LAUNCH"

#Recognized target_disk $target_disk, boot partition $BOOT_PARTITION and FSYS partition $FSYS_PARTITION.
while true; do
    read -p "-> Installing grub bootloader to $BOOT_PARTITION with $FSYS_PARTITION mounted to root both on disk $target_disk. Proceed? (y/n)" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done


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
echo -e "### Grub re-installer: grub.sh: OK"
echo ''

