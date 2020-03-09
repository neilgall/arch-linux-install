#!/bin/bash
# Run as non-root user

PACMAN="sudo pacman --noconfirm"
SYSTEMCTL="sudo systemctl"

# Update system
$PACMAN -Syu

# Install generic packages
$PACMAN -S bash-completion lsof $PACMAN-contrib htop man

# Install compression tools
$PACMAN -S zip unzip unrar

# Install network tools
$PACMAN -S rsync traceroute bind-tools speedtest-cli openssh openvpn macchanger

# Install services
$PACMAN -S networkmanager xdg-user-dirs networkmanager-openvpn

# Enable NetworkManager and disable dhcpcd at boot
$SYSTEMCTL enable NetworkManager
$SYSTEMCTL disable dhcpcd

# Create default directories
sudo xdg-user-dirs-update

# Install File system tools
$PACMAN -S dosfstools ntfs-3g exfat-utils

# Install sound utilities
$PACMAN -S alsa-utils alsa-plugins pulseaudio pulseaudio-alsa

# Install xorg
$PACMAN -S xorg-server xorg-xinit

# Install xorg default fonts
$PACMAN -S font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1

# Install video driver
lspci | grep -e VGA -e 3D
$PACMAN -Ssq xf86-video
$PACMAN -S xf86-video-intel

# Install printer config
$PACMAN -S system-config-printer cups
$SYSTEMCTL enable org.cups.cupsd.service

# Install desktop environment
$PACMAN -S gnome gnome-terminal pamac-manager

# Install default display manager
$PACMAN -S lightdm-gtk-greeter

# Install yay
pacman --nocpnfirm -S go
mkdir /tmp/aur && cd /tmp/aur
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install display manager and settings from AUR
yay -S lightdm-slick-greeter
yay -S lightdm-settings

# Edit /etc/lightdm/lightdm.conf, uncomment and change to
greeter-session=lightdm-slick-greeter

# Enable lightdm greeter
$SYSTEMCTL enable lightdm

# Screen lock
$PACMAN -S xorg-xfontsel xorg-xlsfonts xorg-fonts-misc
yay -S sxlock-git
cp -f sxlock.service /lib/systemd/system
systemctl enable sxlock.service

# Install themes
$PACMAN -S arc-icon-theme arc-gtk-theme papirus-icon-theme

# Install password manager
$PACMAN -S snapd
$SYSTEMCTL enable snapd
$SYSTEMCTL start snapd
sudo snap install nordpass

# Install dev tools
$PACMAN -S aws-cli python-pip nodejs npm

# Install other apps
$PACMAN -S chromium firefox transmission-gtk gedit gedit-plugins vlc flameshot ffmpeg libreoffice-fresh gparted

# Install other apps from AUR
yay -S insomnia
yay -S pacman-cleanup-hook
yay -S zoom
yay -S spotify
yay -S station
yay -S caffeine-ng
