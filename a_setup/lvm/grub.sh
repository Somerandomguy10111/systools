
# Initialize variables
BOOT_PARTITION=""
FSYS_PARTITION=""
target_disk='/dev/nvme0n1'

# Process command line arguments
for arg in "$@"
do
    case $arg in
        --boot_partition=*)
        BOOT_PARTITION="${arg#*=}"
        shift
        ;;
        --fsys_partition=*)
        FSYS_PARTITION="${arg#*=}"
        shift
        ;;
        *)
        echo "Unknown parameter: $arg"
        exit 1
        ;;
    esac
done


# Check if both required arguments are provided
if [[ -z "$BOOT_PARTITION" || -z "$FSYS_PARTITION" ]]; then
    echo "Usage: $0 --boot_partition=/dev/sdX --fsys_partition=/dev/sdY"
    exit 1
fi

# Rest of your script...
#echo "Boot Partition: $BOOT_PARTITION"
#echo "Filesystem Partition: $FSYS_PARTITION"

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
