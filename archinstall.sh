#!/bin/bash

set -e
set -o pipefail

setfont ter-120n
echo "Please set everything to /mnt and /mnt/boot"
echo "I use /boot only, not /boot/efi"

# Update keyring
echo "Installing Archlinux-keyring"
pacman -Sy archlinux-keyring --noconfirm

echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"

# CPU Selection
read -p "Is your CPU AMD or Intel? " cpu_type

# Install base packages
base_packages=(base base-devel linux linux-firmware sof-firmware networkmanager neovim bluez bluez-utils git fish bash pipewire pipewire-pulse)
[[ "$cpu_type" == "intel" ]] && base_packages+=(intel-ucode) || base_packages+=(amd-ucode)

pacstrap /mnt "${base_packages[@]}" --noconfirm --needed

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# User setup
echo "Please provide details for the new user:"
read -p "Enter username: " username
read -p "Enter full name: " fullname
read -p "Enter password: " userpassword
read -p "Enter hostname: " hostname
read -p "Enter the default shell for the user (e.g., /bin/bash, /usr/bin/fish): " usershell

# Bootloader selection
read -p "Do you want to install GRUB or systemd-boot? (grub/systemd-boot): " bootloader

# Check for NVIDIA GPU
gpu_vendor=$(lspci | grep -i VGA | grep -i nvidia)
if [[ -n "$gpu_vendor" ]]; then
    echo "NVIDIA GPU detected. Installing drivers..."
    pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
fi

# Write post-installation script
cat <<EOF > /mnt/next.sh
#!/bin/bash
set -e
set -o pipefail

# User setup
useradd -m -s "$usershell" "$username"
usermod -c "$fullname" "$username"
usermod -aG wheel,storage,power,audio,video "$username"
echo "$username:$userpassword" | chpasswd

# Enable sudo for wheel group
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Locale and timezone setup
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Hostname and networking setup
echo "$hostname" > /etc/hostname
cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain  $hostname
HOSTS

systemctl enable NetworkManager bluetooth

# Bootloader installation
if [[ "$bootloader" == "grub" ]]; then
    pacman -S grub efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager"
    grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$bootloader" == "systemd-boot" ]]; then
    bootctl install
    cat <<LOADER > /boot/loader/loader.conf
default arch
timeout 5
editor 0
LOADER
    cat <<ENTRY > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=\$(blkid -s PARTUUID -o value /dev/sdX) rw
ENTRY
fi

# Desktop Environment installation
read -p "Do you want to install a Desktop Environment (Hyprland/KDE/GNOME)? (yes/no): " install_de
if [[ "$install_de" == "yes" ]]; then
    read -p "Choose Desktop Environment (Hyprland/KDE/GNOME): " de
    case "$de" in
        hyprland)
            pacman -S hyprland waybar rofi wofi alacritty grim slurp xdg-desktop-portal-hyprland --noconfirm --needed
            ;;
        kde)
            pacman -S plasma kde-applications sddm --noconfirm --needed
            systemctl enable sddm
            ;;
        gnome)
            pacman -S gnome gnome-tweaks gdm --noconfirm --needed
            systemctl enable gdm
            ;;
        *)
            echo "Invalid choice. Skipping DE installation."
            ;;
    esac
fi

# Reboot prompt
read -p "Do you want to reboot now? (yes/no): " reboot_now
if [[ "$reboot_now" == "yes" ]]; then
    reboot
fi

echo "-------------------------------------------------"
echo "Installation Complete! Reboot your system."
echo "-------------------------------------------------"
EOF

# Make script executable
chmod +x /mnt/next.sh

# Chroot and run the next setup script
echo "Entering chroot and continuing setup..."
arch-chroot /mnt bash /next.sh
