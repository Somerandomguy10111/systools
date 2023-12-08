#!/bin/bash

# Function to map UUID to its device path
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

# Reading UUID
#read -p "Enter UUID: " uuid

# Mapping
#dev_path=$(map_uuid_to_dev $uuid)

# Output
#echo "Device Path: $dev_path"

map_uuid_to_dev() {
   for dev in $(blkid | cut -d: -f1); do
	dev_uuid=$(blkid -o value -s UUID $dev)
	if [ "$dev_uuid" = "$1" ]; then
#	if [ true ]; then
		echo $dev
	fi
   done
}

echo $(map_uuid_to_dev $1)

