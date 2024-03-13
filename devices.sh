#!/bin/bash
# Provides logical names for all given devices


# To find the logical name from a known identifier
# look up id in /dev/disk/by-id
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

disk0_id=nvme-CT1000P3SSD8_2322E6DD0462
disk1_id=nvme-CT1000P3SSD8_2322E6DC74EB
disk2_id=usb-SSK_SD30_0_1TB_ABCDEFA75101-0:0
disk0_p1="$disk0_id-part1"
disk0_p2="$disk0_id-part2"
disk1_p1="$disk1_id-part2"
disk1_p2="$disk1_id-part2"
disk2_p1="$disk2_id-part1"
disk2_p2="$disk2_id-part2"


export disk0=$(id_to_name $disk0_id)
export disk1=$(id_to_name $disk1_id)
export disk2=$(id_to_name $disk2_id)

export boot0=$(id_to_name $disk0_p1)
export fsys0=$(id_to_name $disk0_p2)

echo -e "### Device recognition: device.sh"

export boot1=$(id_to_name $disk1_p1)
export fsys1=$(id_to_name $disk1_p2)
export boot2=$(id_to_name $disk2_p1)
export fsys2=$(id_to_name $disk2_p2)
echo -e "->Recognized disks:\ndisk0 $disk0;\ndisk1 $disk1;\ndisk2 $disk2"
echo -e "->Recognized partitions:\nboot0 $boot0;\nfsys0 $fsys0;\nboot1 $boot1; \nfsys1 $fsys1; \nboot2 $boot2; \nfsys2 $fsys2\n"

echo -e "### Device recognition: device.sh: OK\n"
echo -e "done"
