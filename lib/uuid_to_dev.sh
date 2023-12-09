#!/bin/bash

# To find the logical name from a known identifier
id_to_logical_name() {
    identifier=$1
    logical_name=$(readlink -f /dev/disk/by-id/"$identifier")
    echo "$logical_name"
}

