#!/bin/bash

source lib/name_resolution.sh

# Input parameters
part_id="dm-name-VG-lv_nvme0n1p2"

#---------------------#
#!/bin/bash

# Function to get the full logical volume path
get_full_lv_path() {
    local dev=$1
    local vg_name
    local lv_name

    vg_name=$(dmsetup info -c --noheadings -o vg_name "$dev")
    lv_name=$(dmsetup info -c --noheadings -o lv_name "$dev")
    echo "/dev/$vg_name/$lv_name"
}

# Function to create a snapshot of the logical volume
create_snapshot() {
    local lv_path=$1
    local snapshot_size="10G"
    local snapshot_name

    snapshot_name="snapshot_$(date +%Y%m%d_%H%M%S)"

    echo "-> Creating snapshot $snapshot_name of size $snapshot_size for $lv_path"

    if lvcreate --size "$snapshot_size" --snapshot --name "$snapshot_name" "$lv_path"; then
        echo "-> Snapshot created successfully: $snapshot_name"
    else
        echo "-> Error: Failed to create snapshot."
        return 1
    fi
}


# Main script logic
part_id="dm-name-VG-lv_nvme0n1p2"
fsys_dev=$(id_to_logical_name "$part_id")
full_lv_path=$(get_full_lv_path "$fsys_dev")

echo "-> Found logical volume: $full_lv_path"

create_snapshot "$full_lv_path"
