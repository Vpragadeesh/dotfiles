#!/bin/bash

set -e
set -o pipefail

setfont ter-120n
echo "Please ensure everything is set to /mnt and /mnt/boot"
echo "I use /boot only, not /boot/efi"

# Update keyring
echo "Updating Archlinux-keyring"
pacman -Sy archlinux-keyring --noconfirm

echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"

# CPU Selection with default to Intel
read -p "Is your CPU AMD or Intel? (Default: Intel) " cpu_type
cpu_type=${cpu_type:-intel}

# Install base packages
base_packages=(base base-devel linux linux-firmware sof-firmware networkmanager neovim bluez bluez-utils git fish bash)
[[ "$cpu_type" == "intel" ]] && base_packages+=(intel-ucode) || base_packages+=(amd-ucode)

pacstrap /mnt "${base_packages[@]}" --noconfirm --needed

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# User setup with defaults
read -p "Enter username (default: user): " username
username=${username:-user}
read -p "Enter full name (default: User Name): " fullname
fullname=${fullname:-"User Name"}
read -s -p "Enter password: " userpassword
echo
read -p "Enter hostname (default: arch-linux): " hostname
hostname=${hostname:-arch-linux}
read -p "Enter the default shell for the user (default: /usr/bin/fish): " usershell
usershell=${usershell:-/usr/bin/fish}

# Bootloader selection with default to systemd-boot
read -p "Do you want to install GRUB or systemd-boot? (Default: systemd-boot) " bootloader
bootloader=${bootloader:-systemd-boot}

# Check for NVIDIA GPU
gpu_vendor=$(lspci | grep -i VGA | grep -i nvidia)
if [[ -n "$gpu_vendor" ]]; then
    echo "NVIDIA GPU detected."
    read -p "Do you want to install NVIDIA drivers now? (now/later): " nvidia_choice
    if [[ "$nvidia_choice" == "now" ]]; then
        echo "Installing NVIDIA drivers..."
        pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
    else
        echo "NVIDIA drivers installation will be skipped for now."
        echo "You can install them later with: pacman -S nvidia nvidia-utils nvidia-settings"
    fi
else
    echo "No NVIDIA GPU detected."
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
else
    bootctl install
    cat <<LOADER > /boot/loader/loader.conf
default arch
timeout 5
editor 0
LOADER
    root_uuid=\$(blkid -s UUID -o value /dev/sdX)
    cat <<ENTRY > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=\$root_uuid rw
ENTRY
fi

# Desktop Environment installation
read -p "Do you want to install a Desktop Environment? (Default: no) " install_de
install_de=${install_de:-no}
if [[ "$install_de" == "yes" ]]; then
    read -p "Choose Desktop Environment (Hyprland/KDE/GNOME, Default: KDE): " de
    de=${de:-kde}
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

echo "-------------------------------------------------"
echo "Installation Complete! You may now reboot."
echo "-------------------------------------------------"
EOF

# Make script executable
chmod +x /mnt/next.sh

# Chroot and run the next setup script
echo "Entering chroot and continuing setup..."
arch-chroot /mnt bash /next.sh
