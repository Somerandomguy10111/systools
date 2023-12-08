#!/bin/bash

#map_uuid_to_dev() {
#    for dev in $(blkid | cut -d: -f1); do
#        uuid=$(blkid -s UUID -o value $dev)
#        if [ "$uuid" = "$1" ]; then
#            echo $dev
#            return
#        fi
#    done
#    echo "No device found for UUID $1"
#}

#read -p "Enter UUID: " uuid

#dev_path=$(map_uuid_to_dev $uuid)

#echo "Device Path: $dev_path"

# To find the logical name from a known identifier
identifier="nvme-nvme.c0a9-323332324536444430343632-435431303030503353534438-00000001"
logical_name=$(readlink -f /dev/disk/by-id/$identifier)
echo $logical_name

# To find the identifier from a known logical name
#logical_name="/dev/sda"
#identifier=$(ls -l /dev/disk/by-id/ | grep "$logical_name$" | awk '{print $9}')
#echo "Identifier: $identifier"

