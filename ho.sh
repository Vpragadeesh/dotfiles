#!/bin/bash
set -e
set -o pipefail

# Collect user input
echo "Enter full name:"; read fullname
echo "Enter username:"; read username
echo "Enter password:"; read -s userpassword
echo "Enter hostname:"; read hostname
echo "Enter bootloader (grub/systemd):"; read bootloader
echo "Enter root partition (e.g., /dev/sdX1):"; read root_partition

# Configure user
usermod -c "$fullname" "$username"
usermod -aG wheel,storage,power,audio,video "$username"
echo "$username:$userpassword" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Locale and timezone setup
echo "$hostname" > /etc/hostname
ln -sf /usr/share/zoneinfo/$(curl -s https://ipapi.co/timezone) /etc/localtime
hwclock --systohc

echo "127.0.1.1   $hostname.localdomain  $hostname" > /etc/hosts

# Enable essential services
systemctl enable NetworkManager bluetooth

# Bootloader installation
if [[ "$bootloader" == "grub" ]]; then
    pacman -S grub efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager"
    grub-mkconfig -o /boot/grub/grub.cfg
else
    bootctl install
    cat <<BOOT > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=$(blkid -s UUID -o value "$root_partition") rw
BOOT
fi

echo "-------------------------------------------------"
echo "Installation Complete! You may now reboot."
echo "-------------------------------------------------"
