##Update grub
#echo "Mounting the root partition..."
#sudo mount $ROOT_PARTITION /mnt
#
## Bind necessary directories
#echo "Binding /dev, /sys, and /proc..."
#sudo mount --bind /dev /mnt/dev
#sudo mount --bind /sys /mnt/sys
#sudo mount --bind /proc /mnt/proc
#
## Mount the boot partition if it's separate
#if [ -n "$BOOT_PARTITION" ]; then
#    echo "Mounting the boot partition..."
#    sudo mount $BOOT_PARTITION /mnt/boot
#fi
#
## Chroot into the mounted filesystem
#echo "Entering chroot environment..."
#sudo chroot /mnt
#
## Inside the chroot environment
#echo "Updating GRUB configuration..."
#sudo update-grub
#
## Exit chroot
#echo "Exiting chroot..."
#exit
#
## Unmount filesystems
#echo "Unmounting filesystems..."
#sudo umount /mnt/dev
#sudo umount /mnt/sys
#sudo umount /mnt/proc
#
#if [ -n "$BOOT_PARTITION" ]; then
#    sudo umount /mnt/boot
#fi
#
#sudo umount /mnt
#
#echo "GRUB update process complete. Please reboot your system."