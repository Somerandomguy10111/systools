#!/bin/bash

source devices.sh

#---------------------#
#!/bin/bash

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



create_snapshot "$fsys1"
