threshold_size=20  # Threshold for shrinking in GB

#---------------------#

# Function to check if space is available for shrinking
check_space_for_shrinking() {
    local lv_path=$1
    local threshold_size=20  # Threshold for shrinking in GB
    local current_usage
    local total_lv_size
    local free_space

    # Assign values in separate statements
    current_usage=$(df --output=used -BG "$lv_path" | tail -n 1 | tr -dc '0-9')
    total_lv_size=$(lsblk -b -d -n -o SIZE "$lv_path" | awk '{print int($1/1024/1024/1024)}')
    free_space=$((total_lv_size - current_usage))

    echo "Current usage of filesystem: $current_usage GB"
    echo "Total size of logical volume: $total_lv_size GB"
    echo "Available space for shrinking: $free_space GB"

    if [ "$free_space" -gt "$threshold_size" ]; then
        return 0  # Space is available for shrinking
    else
        return 1  # Not enough space for shrinking
    fi
}

# Function to safely shrink the logical volume
shrink_volume() {
    local lv_path=$1

    echo "Shrinking volume by $threshold_size GB"
    lvreduce --resizefs --size -${threshold_size}G "$lv_path"
}