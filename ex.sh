#!/bin/bash
set -e
set -o pipefail
setfont ter-120n

# Partition formatting and mounting
echo "--------------------------------------------------"
echo "-- Partition Setup: Formatting and Mounting     --"
echo "--------------------------------------------------"
read -p "Enter your root partition (e.g., /dev/sda2): " root_partition
read -p "Enter your boot partition (e.g., /dev/sda1): " boot_partition

# Ensure partitions exist
if [[ ! -b "$root_partition" || ! -b "$boot_partition" ]]; then
    echo "Error: One or both partitions do not exist. Exiting."
    exit 1
fi

echo "Formatting root partition ($root_partition) as ext4..."
mkfs.ext4 -F "$root_partition"
echo "Formatting boot partition ($boot_partition) as FAT32..."
mkfs.fat -F32 "$boot_partition"

echo "Mounting root partition to /mnt..."
mount "$root_partition" /mnt
mkdir -p /mnt/boot
mount "$boot_partition" /mnt/boot

echo "Updating Archlinux-keyring"
pacman -Sy archlinux-keyring --noconfirm

# Install base system
base_packages=(base base-devel linux linux-firmware sof-firmware networkmanager neovim bluez bluez-utils git fish bash)
read -p "Is your CPU AMD or Intel? (Default: Intel) " cpu_type
cpu_type=${cpu_type,,}  # Convert to lowercase
[[ "$cpu_type" == "amd" ]] && base_packages+=(amd-ucode) || base_packages+=(intel-ucode)

pacstrap /mnt "${base_packages[@]}" --noconfirm --needed

echo "Generating fstab"
genfstab -U /mnt >> /mnt/etc/fstab

# User setup
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

# Bootloader selection
read -p "Do you want to install GRUB or systemd-boot? (Default: systemd-boot) " bootloader
bootloader=${bootloader,,}
[[ "$bootloader" != "grub" && "$bootloader" != "systemd-boot" ]] && bootloader="systemd-boot"

# Check for NVIDIA GPU
gpu_vendor=$(lspci | grep -i VGA | grep -i nvidia)
if [[ -n "$gpu_vendor" ]]; then
    read -p "NVIDIA GPU detected. Install drivers now? (now/later): " nvidia_choice
    [[ "$nvidia_choice" == "now" ]] && pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
fi

# Write post-installation script
cat <<EOF > /mnt/next.sh
#!/bin/bash
set -e
set -o pipefail

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
EOF

chmod +x /mnt/next.sh
echo "Entering chroot and continuing setup..."
arch-chroot /mnt bash /next.sh
