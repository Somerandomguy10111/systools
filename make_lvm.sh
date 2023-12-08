part_name="nvme1n1"
vg_name="TheVolumeGroup"
lv_name="TheLogicalVolume"
mnt_name="my_lv"

sudo pvcreate /dev/$part_name
sudo vgcreate MyVolumeGroup /dev/$part_name
sudo lvcreate -L 100G -n $lv_name $vg_name
sudo mkfs.ext4 /dev/$vg_name/$lv_name
sudo mkdir /mnt/$mnt_name
sudo mount /dev/$vg_name/$lv_name /mnt/$mnt_name
