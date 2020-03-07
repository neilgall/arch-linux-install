# Update system
pacman --noconfirm -Syu

# Install yay
mkdir /tmp/aur && cd /tmp/aur
git clone https://aur.archlinux.org/yay.git
cd yay
cat PKGBUILD
makepkg -si

# Install generic packages
pacman --noconfirm -S bash-completion lsof pacman --noconfirm-contrib htop

# Install compression tools
pacman --noconfirm -S zip unzip unrar

# Install network tools
pacman --noconfirm -S rsync traceroute bind-tools speedtest-cli openssh openvpn macchanger

# Install services
pacman --noconfirm -S networkmanager xdg-user-dirs networkmanager-openvpn

# Enable NetworkManager and disable dhcpcd at boot
systemctl enable NetworkManager
systemctl disable dhcpcd

# Create default directories
xdg-user-dirs-update

# Install File system tools
pacman --noconfirm -S dosfstools ntfs-3g exfat-utils

# Install sound utilities
pacman --noconfirm -S alsa-utils alsa-plugins pulseaudio pulseaudio-alsa

# Install xorg
pacman --noconfirm -S xorg-server xorg-xinit

# Install xorg default fonts
pacman --noconfirm -S font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf ttf-bitstream-vera ttf-dejavu ttf-liberation xorg-fonts-type1

# Install video driver
lspci | grep -e VGA -e 3D
pacman --noconfirm -Ssq xf86-video
pacman --noconfirm -S xf86-video-intel

# Install printer config
pacman --noconfirm -S system-config-printer cups
systemctl enable org.cups.cupsd.service

# Install desktop environment
pacman --noconfirm -S gnome gnome-terminal pamac-manager

# Install default display manager
pacman --noconfirm -S lightdm-gtk-greeter

# Install display manager and settings from AUR
yay -S lightdm-slick-greeter
yay -S lightdm-settings

# Edit /etc/lightdm/lightdm.conf, uncomment and change to
greeter-session=lightdm-slick-greeter

# Restart lightdm service
systemctl restart lightdm.service

# Enable lightdm greeter
systemctl enable lightdm

# Install themes
pacman --noconfirm -S arc-icon-theme arc-gtk-theme papirus-icon-theme

# Install password manager
pacman --noconfirm -S snapd
systemctl enable snapd
systemctl start snapd
snap install nordpass

# Install dev tools
pacman --noconfirm -S aws-cli python-pip nodejs npm

# Install other apps
pacman --noconfirm -S chromium firefox transmission-gtk virtualbox gedit gedit-plugins vlc flameshot ffmpeg libreoffice-fresh gparted

# Install other apps from AUR
yay -S insomnia
yay -S postman-bin
yay -S pacman --noconfirm-cleanup-hook
yay -S zoom
yay -S spotify
yay -S station
yay -S caffeine-ng
