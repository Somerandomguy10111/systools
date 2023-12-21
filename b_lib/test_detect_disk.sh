    # Function to get physical disk from a logical volume path
    get_physical_disk_from_lv() {
        local dev=$1

        # Extract VG from the LV path
    vg_name=$(dmsetup info -c --noheadings -o vg_name "$dev")
        local disk=$(sudo pvs --noheadings --select vg_name="$vg_name" -o pv_name)

        echo "$disk"
    }



disk=$(get_physical_disk_from_lv "/dev/dm-0")
echo "Physical Disk: $disk"

