#!/bin/bash
# Provides logical names for all given devices


# To find the logical name from a known identifier
id_to_name() {
    identifier=$1
    logical_name=$(readlink -f /dev/disk/by-id/"$identifier")

    full_lv_path=$(get_full_lv_path "$logical_name" 2> /dev/null)
    if [ $? -eq 0 ]; then
        echo "$full_lv_path"
    else
        echo "$logical_name"
    fi
}


get_full_lv_path() {
    local dev=$1
    local vg_name
    local lv_name

    vg_name=$(sudo dmsetup info -c --noheadings -o vg_name "$dev" 2> /dev/null)
    lv_name=$(sudo dmsetup info -c --noheadings -o lv_name "$dev" 2> /dev/null)

    if [ -z "$vg_name" ] || [ -z "$lv_name" ]; then
        return 1
    fi

    echo "/dev/$vg_name/$lv_name"
}


disk0=$(id_to_name nvme-CT1000P3SSD8_2322E6DD0462)
disk1=$(id_to_name nvme-CT1000P3SSD8_2322E6DC74EB)

boot0=$(id_to_name nvme-CT1000P3SSD8_2322E6DD0462_1-part1)
fsys0=$(id_to_name nvme-CT1000P3SSD8_2322E6DD0462_1-part2)

echo -e "### Device recognition: device.sh"
echo -e "Recognized devices:\n->disk0 $disk0;\n->disk1 $disk1;\n->boot0 $boot0;\n->fsys0 $fsys0"

boot1=$(id_to_name nvme-CT1000P3SSD8_2322E6DC74EB-part1)
fsys1=$(id_to_name dm-name-VG-fsys)
echo -e "-> boot1 $boot1;\n->fsys1 $fsys1"


echo -e "### Device recognition: device.sh: OK\n"