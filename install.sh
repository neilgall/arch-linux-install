set -e

# Increate console font size
echo 'FONT=latarcyrheb-sun32' > /etc/vconsole.conf
systemctl restart systemd-vconsole-setup

# Connect to the internet
ip link

# Verify network connection
ping -c 5 archlinux.org

# Update the system clock
timedatectl set-ntp true

# Partition the disks
cgdisk /dev/nvme0n1
# 1 512MB EFI partition - Hex code ef00
# 2 100% size partiton (to be encrypted) - Hex code 8300

# Format the partitions
mkfs.vfat -F32 /dev/nvme0n1p1

# Setup the encryption of the system
cryptsetup -c aes-xts-plain64 -s 512 -y --use-random luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 luks

# Create encrypted partitions
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 16G vg0 --name swap
lvcreate --size 64G vg0 --name root
lvcreate -l +100%FREE vg0 --name home

# Create filesystems on encrypted partitions
mkfs.ext4 /dev/mapper/vg0-root
mkfs.ext4 /dev/mapper/vg0-home
mkswap /dev/mapper/vg0-swap

# Mount the file systems
mount /dev/mapper/vg0-root /mnt
mkdir /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot
mkdir /mnt/home
mount /dev/mapper/vg0-home /mnt/home
swapon /dev/mapper/vg0-swap

# Select the mirrors
curl -o /etc/pacman.d/mirrorlist "https://www.archlinux.org/mirrorlist/?country=GB&protocol=https&ip_version=4&use_mirror_status=on"
sed -i 's/\#Server/Server/g' /etc/pacman.d/mirrorlist

# Install essential packages and optional tools
pacstrap /mnt base base-devel linux linux-firmware vi vim efibootmgr lvm2 dialog wpa_supplicant iw dhcpcd netctl git

# Generate fstab file
genfstab -pU /mnt >> /mnt/etc/fstab

# Make /tmp a ramdisk
echo 'tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0' >> /mnt/etc/fstab

# Chroot to new system
arch-chroot /mnt /bin/bash

# Unmount all partitions
umount -R /mnt
swapoff -a

# Reboot into the new system
reboot
