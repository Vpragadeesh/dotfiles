setfont ter-120n
echo "Please set all thing /mnt and /mnt/boot"
echo "I use /boot only not /boot/efi"

echo "Installing Archlinux-keyring"
pacman -Sy archlinux-keyring

echo "This install will install only base install "
echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"
echo ""

# CPU Selection
read -sp "Is your CPU AMD or Intel? " igpu
echo

# Install base packages
if [ "$igpu" = "intel" ]; then
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager intel-ucode neovim bluez bluez-utils git fish --noconfirm --needed
else 
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager amd-ucode neovim bluez bluez-utils git fish --noconfirm --needed
fi

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Prompt for user details
echo "Please provide details for the new user:"
read -p "Enter username: " username
read -p "Enter full name: " fullname
read -sp "Enter password: " userpassword
read -p "Enter hostname: " hostname
echo
read -p "Enter the default shell for the user (e.g., /bin/bash, /usr/bin/fish): " usershell

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
::1			localhost
127.0.1.1	$hostname.localdomain	$hostname
EOF

# Audio Drivers
echo "-------------------------------------------------"
# Enable services
systemctl enable NetworkManager bluetooth
echo "network and bluetooth started"
echo "-------------------------------------------------"

# Bootloader installation
echo "--------------------------------------"
echo "-- Bootloader Installation --"
echo "--------------------------------------"
echo "This will install the GRUB in /boot"
echo "--------------------------------------"

pacman -S grub efibootmgr --noconfirm --needed
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager" --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg

echo "-------------------------------------------------"
echo "Install Complete, You can reboot now"
echo "-------------------------------------------------"
REALEND

# Chroot into the installed system and run the script
arch-chroot /mnt bash /next.sh
