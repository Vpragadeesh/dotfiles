#!/bin/bash

setfont ter-120n
echo "Please set everything to /mnt and /mnt/boot"
echo "I use /boot only, not /boot/efi"

echo "Installing Archlinux-keyring"
pacman -Sy archlinux-keyring --noconfirm

echo "This install will install only base install "
echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"

# CPU Selection
read -p "Is your CPU AMD or Intel? " igpu

# Install base packages
if [[ "$igpu" == "intel" ]]; then
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager intel-ucode neovim bluez bluez-utils git fish bash pipewire pipewire-pulse --noconfirm --needed
else 
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager amd-ucode neovim bluez bluez-utils git fish bash pipewire pipewire-pulse --noconfirm --needed
fi

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Prompt for user details
echo "Please provide details for the new user:"
read -p "Enter username: " username
read -p "Enter full name: " fullname
read -s -p "Enter password: " userpassword
echo
read -p "Enter hostname: " hostname
read -p "Enter the default shell for the user (e.g., /bin/bash, /usr/bin/fish): " usershell

# Additional Software Selection
read -p "Do you want to install a Desktop Environment (Hyprland/KDE/GNOME)? (yes/no): " install_de

# Bootloader Selection
read -p "Do you want to install GRUB or systemd-boot? (grub/systemd-boot): " bootloader

# Check for NVIDIA GPU
gpu_vendor=$(lspci | grep -i VGA | grep -i nvidia)
if [[ ! -z "$gpu_vendor" ]]; then
    echo "NVIDIA GPU detected. Installing drivers..."
    pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
fi

# Write next.sh with dynamic inputs
cat <<REALEND > /mnt/next.sh
#!/bin/bash

# Add user with the specified shell
useradd -m -s "$usershell" "$username"
usermod -c "$fullname" "$username"
usermod -aG wheel,storage,power,audio,video "$username"
echo "$username:$userpassword" | chpasswd

# Sudoers setup
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Locale and timezone
echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Hostname and hosts file
echo "$hostname" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF

# Enable services
systemctl enable NetworkManager bluetooth
echo "NetworkManager and Bluetooth enabled"

# Bootloader installation
echo "--------------------------------------"
echo "-- Bootloader Installation --"
echo "--------------------------------------"
    pacman -S grub efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager"
    grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$bootloader" == "systemd-boot" ]]; then
    bootctl install
    cat <<EOF > /boot/loader/loader.conf
default arch
timeout 5
editor 0
EOF

    cat <<EOF > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value /dev/sdX) rw
EOF
fi

# Install a Desktop Environment if selected
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

# Reboot option
read -p "Do you want to reboot now? (yes/no): " reboot_now
if [[ "$reboot_now" == "yes" ]]; then
    reboot
fi

echo "-------------------------------------------------"
echo "Installation Complete! Reboot your system."
echo "-------------------------------------------------"
REALEND

# Make script executable
chmod +x /mnt/next.sh

# Chroot into the installed system and run the script
arch-chroot /mnt bash /next.sh
