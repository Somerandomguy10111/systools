#!/bin/bash

# To find the logical name from a known identifier
id_to_logical_name() {
    identifier=$1
    logical_name=$(readlink -f /dev/disk/by-id/"$identifier")
    echo "$logical_name"
}


get_full_lv_path() {
    local dev=$1
    local vg_name
    local lv_name

    vg_name=$(dmsetup info -c --noheadings -o vg_name "$dev")
    lv_name=$(dmsetup info -c --noheadings -o lv_name "$dev")

    echo "/dev/$vg_name/$lv_name"
}
