#For backups of an Ubuntu 22.04 LVM


## --no-vram option necessary when booting from USB stick
see: https://askubuntu.com/questions/1170347/what-does-no-nvram-do-while-installing-grub
For a device which is not normally attached to a motherboard (i.e. USB hard disk) it does not make sense to store this entry in the motherboard's NVRAM as the device might not be there during most boots. I believe the --no-nvram option tells the grub-installer not to modify the motherboard's NVRAM for this purpose.


