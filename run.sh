main_partition='the_volume'



sudo lvcreate --size 50GB --snapshot --name backupSnapshot /dev/$(main_partition)

