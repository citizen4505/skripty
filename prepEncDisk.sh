#!/bin/bash
echo "disk name (ex.: /dev/sdx): "
read disk
echo "disk label: "
read diskLabel
#echo "select partition(ext4. ext3, ext2, ntfs, fat, fat32, exfat): "

sudo cryptsetup --verbose --verify-passphrase luksFormat $disk
sudo cryptsetup luksOpen $disk prepEncDisk
sudo mkfs.ext4 -L $diskLabel /dev/mapper/prepEncDisk
sudo cryptsetup luksClose /dev/mapper/prepEncDisk 