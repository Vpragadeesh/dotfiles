setfont ter-120n
echo "Please set all thing /mnt and /mnt/boot"
echo "I use /boot only not /boot/efi"

echo "Installing Archlinux-keyring"
pacman -Sy archlinux-keyring

echo "This install will install the base system along with your chosen Desktop Environment and additional packages"
echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux with DE --"
echo "--------------------------------------"

# CPU Selection
read -p "Is your CPU AMD or Intel? " igpu
echo

# Prompt for Desktop Environment selection:
echo "Select your Desktop Environment:"
echo "Options: gnome, plasma, xfce"
read -p "Enter your choice: " de_choice

# Determine DE packages based on selection (including display manager):
de_packages=""
case "$de_choice" in
  gnome|Gnome)
    de_packages="gnome gnome-extra gdm"
    ;;
  plasma|Plasma)
    de_packages="plasma sddm"
    ;;
  xfce|Xfce)
    de_packages="xfce4 xfce4-goodies lightdm lightdm-gtk-greeter"
    ;;
  *)
    echo "No valid Desktop Environment selected. Proceeding without DE."
    ;;
esac

# Prompt for additional packages to install:
read -p "Enter any additional packages to install (separated by spaces, or leave blank to skip): " additional_packages

# Install base packages along with DE and additional packages:
if [ "$igpu" = "intel" ]; then
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager intel-ucode neovim bluez bluez-utils git fish bash $de_packages $additional_packages --noconfirm --needed
else 
  pacstrap /mnt base base-devel linux linux-firmware sof-firmware networkmanager amd-ucode neovim bluez bluez-utils git fish bash $de_packages $additional_packages --noconfirm --needed
fi

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Prompt for user details
echo "Please provide details for the new user:"
read -p "Enter username: " username
read -p "Enter full name: " fullname
read -sp "Enter password: " userpassword
echo
read -p "Enter hostname: " hostname
echo
read -p "Enter the default shell for the user (e.g., /bin/bash, /usr/bin/fish): " usershell

# Write next.sh with dynamic inputs and service enablement
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

# Enable core services
systemctl enable NetworkManager bluetooth
echo "NetworkManager and bluetooth services enabled"

# Bootloader installation
echo "--------------------------------------"
echo "-- Bootloader Installation --"
echo "--------------------------------------"
echo "This will install GRUB in /boot"
echo "--------------------------------------"
pacman -S grub efibootmgr --noconfirm --needed
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager" --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg

# Enable the chosen Desktop Environment's display manager:
case "$de_choice" in
  gnome|Gnome)
    systemctl enable gdm
    echo "Gnome Display Manager (GDM) enabled"
    ;;
  plasma|Plasma)
    systemctl enable sddm
    echo "Plasma Display Manager (SDDM) enabled"
    ;;
  xfce|Xfce)
    systemctl enable lightdm
    echo "XFCE Display Manager (LightDM) enabled"
    ;;
  *)
    echo "No Desktop Environment Display Manager to enable."
    ;;
esac

echo "-------------------------------------------------"
echo "Installation Complete, You can reboot now"
echo "-------------------------------------------------"
REALEND

# Make next.sh executable
chmod +x /mnt/next.sh

# Chroot into the installed system and run the script
arch-chroot /mnt bash /next.sh
