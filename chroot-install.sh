# Set the time zone
ln -s /usr/share/zoneinfo/Europe/London /etc/localtime
hwclock --systohc --utc

# Localization
echo 'en_GB.UTF-8 UTF-8' >> /etc/locale.gen
echo 'en_GB ISO-8859-1' >> /etc/locale.gen
echo 'LANG=en_GB.UTF-8' >> /etc/locale.conf
echo 'LANGUAGE=en_GB' >> /etc/locale.conf
locale-gen

# Persist console font
echo 'FONT=latarcyrheb-sun32' > /etc/vconsole.conf

# Set the hostname
echo 'bawbags' > /etc/hostname

# Update hosts file
echo '127.0.0.1  localhost' >> /etc/hosts
echo '::1        localhost' >> /etc/hosts
echo '127.0.0.1  bawbags.localdomain bawbags' >> /etc/hosts

# Root password
echo "Set root password"
passwd

# Add unprivileged user
echo "Set password for user 'neil'"
useradd -m -g users -G wheel neil
passwd neil

# Edit /etc/suders, uncomment
# %wheel ALL=(ALL) ALL

# Generate a keyfile and add it as a LUKS key
dd bs=512 count=8 if=/dev/random of=/boot/crypto_keyfile.bin iflag=fullblock
chmod 600 /boot/crypto_keyfile.bin
chmod 600 /boot/initramfs-linux*
cryptsetup luksAddKey /dev/nvme0n1p2 /boot/crypto_keyfile.bin

# Configure mkinitcpio
vim /etc/mkinitcpio.conf
# MODULES=(ext4 i915)
# HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt sd-lvm2 resume filesystems fsck)
# FILES=(/boot/crypto_keyfile.bin)

# Regenerate mkinitcpio/initramfs image
mkinitcpio -p linux

# Set up systemd-boot
bootctl --path=/boot install

# Enable Intel microcode updates
pacman -S intel-ucode

# Create boot loader entry
UUID=$(echo $(blkid | grep nvme0n1p2 | cut -d '"' -f 2))
cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /intel-ucode.img
initrd  /initramfs-linux.img
options rd.luks.uuid=#UUID rd.luks.key=/boot/crypto_keyfile.bin root=/dev/mapper/vg0-root resume=/dev/mapper/vg0-swap mem_sleep_default=deep rw splash libata.force=noncq mitigations=off
EOF
sed -i "s/\#UUID/$UUID/g" /boot/loader/entries/arch.conf

# Loader configuration
cat <<EOF > /boot/loader/loader.conf
default  arch
timeout  5
editor   no
EOF

# Update systemd-boot
bootctl --path=/boot update

# Create systemd-boot-pacman hook
mkdir /etc/pacman.d/hooks
cat <<EOF > /etc/pacman.d/hooks/systemd-boot.hook
[Trigger]
Type = Package
Operation = Upgrade
Target = systemd

[Action]
Description = Updating systemd-boot...
When = PostTransaction
Exec = /usr/bin/bootctl --path=/boot update
EOF
