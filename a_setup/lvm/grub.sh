source lib/name_resolution.sh
BOOT_PARTITION="/dev/nvme0n1p1"
FSYS_PARTITION="/dev/VG/lv_sda2"

#---------------------#

get_physical_disk_from_lv() {
    local dev=$1
    # Extract VG from the LV path
    vg_name=$(dmsetup info -c --noheadings -o vg_name "$dev")
    local disk=$(sudo pvs --noheadings --select vg_name="$vg_name" -o pv_name)

    echo "$disk"
}


get_disk_name() {
    local dev=$1

    if lvdisplay "$dev" &> /dev/null; then
        echo $(get_physical_disk_from_lv "$dev")
    else
        echo $(lsblk -no PKNAME "$dev")
    fi
}


#BOOT_PARTITION=$(id_to_logical_name $BOOT_ID)
#FSYS_PARTITION=$(id_to_logical_name $FSYS_ID)
disk=$(get_disk_name "$FSYS_PARTITION")
echo "-> Recognized disk $disk, boot partition $BOOT_PARTITION and FSYS partition $FSYS_PARTITION"

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
echo "-> Reinstalling grub on $disk"
sudo chroot /mnt /bin/bash -c "mount -t efivarfs none /sys/firmware/efi/efivars; grub-install --no-nvram $disk; update-grub; exit"

echo "-> Updating fstab"
sudo chroot /mnt /bin/bash -c "genfstab -U / | grep -v 'loop' > /etc/fstab"


# Unmount filesystems
echo "-> Unmounting filesystems..."
sudo umount -l "$BOOT_PARTITION"
sudo umount -l "$FSYS_PARTITION"

echo "-> GRUB update process complete. Please reboot your system."
echo "done"
