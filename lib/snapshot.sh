#!/bin/bash

source lib/name_resolution.sh

# Input parameters
part_id="dm-name-VG-lv_nvme0n1p2"

#---------------------#

# Function to get the full logical volume path
# Function to get the full logical volume path

# Main script logic
part_id="dm-name-VG-lv_nvme0n1p2"
fsys_dev=$(id_to_logical_name "$part_id")
full_lv_path=$(get_full_lv_path "$fsys_dev")

