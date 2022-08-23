#!/usr/bin/env bash

# Create partition information. fdisk commands were:
# g - convert disk to GPT
# n - new partition
# p - primary partition
# 1 - 1st partition
# Return * 2 - First and last sector defaults (use whole disk)
# 29 - Partition type should be "Linux RAID"
# w - write changes and exit
sudo fdisk /dev/sdb; sudo fdisk /dev/sdc; sudo fdisk /dev/sdd

# Create the actual array. Will start in a degraded state, and rebuild. SLOWLY.
sudo mdadm --create /dev/md0 --level=5 -n 3 /dev/sdb /dev/sdc /dev/sdd

# Copy details from this command into /dev/mdadm/mdadm.conf
sudo mdadm --detail --scan

# View status of array, and rebuild percentage
sudo mdadm --detail /dev/md0

# Write encrypted data to that bad boy
pv /dev/urandom | sudo dd of=/dev/md0 bs=512K

# Initialize the raid array for LVM use
sudo pvcreate /dev/md0
sudo vgcreate vg1 /dev/md0

# Create the logical volume
sudo lvcreate -l 100%VG -n data vg1 /dev/md0

# Encrypt the new logical volume, and mount it
sudo cryptsetup --verbose -c twofish-xts-plain64 -h whirlpool --key-size 512 \
	luksFormat /dev/vg1/data
sudo cryptsetup luksOpen /dev/vg1/data raid

# Create the ext4 partition
sudo mkfs.ext4 /dev/mapper/raid

# Voilla!
sudo mount /dev/mapper/raid /raid

# Generate a random keyfile for unlocking drives
sudo dd bs=4M count=1 if=/dev/random \
	of=/etc/cryptsetup-initramfs/tenenbaum-encryption.key
sudo chmod 600 /etc/cryptsetup-initramfs/tenenbaum-encryption.key

# Add key file to keyslot on RAID volume
sudo cryptsetup luksAddKey /dev/mapper/vg1-data \
	/etc/cryptsetup-initramfs/tenenbaum-encryption.key

# Automatically unlock + mount RAID on boot
echo 'raid_crypt UUID=1d0586cc-281b-497d-8025-99ee3a120e17 /etc/cryptsetup-initramfs/tenenbaum-encryption.key luks,discard' | \
	sudo tee -a /etc/crypttab
echo '/dev/mapper/raid_crypt	/raid	ext4	errors=remount-ro	0	2' | sudo tee -a /etc/fstab

