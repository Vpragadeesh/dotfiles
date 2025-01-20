#!/usr/bin/env bash
#
# setfont ter-132n
# echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1)"
# read EFI
#
# echo "Please enter Root(/) paritition: (example /dev/sda3)"
# read ROOT  
#
# echo "Please enter your Username"
# read USER 
#
# echo "Enter your hostname"
# read HOST
#
# echo "Please enter your Full Name"
# read NAME 
#
# echo "Please enter your Password"
# read PASSWORD 
#
# # make filesystems
# echo -e "\nCreating Filesystems...\n"
#
# existing_fs=$(blkid -s TYPE -o value "$EFI")
# if [[ "$existing_fs" != "vfat" ]]; then
#     mkfs.vfat -F32 "$EFI"
# fi
#
# mkfs.ext4 "${ROOT}"
#
# # mount target
# mount "${ROOT}" /mnt
# ROOT_UUID=$(blkid -s UUID -o value "$ROOT")
# mount --mkdir "$EFI" /mnt/boot
#
#
echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"
pacstrap -K /mnt base base-devel linux linux-firmware sof-firmware networkmanager vim intel-ucode bluez bluez-utils git btop nvtop npm --noconfirm --needed

# fstab
genfstab -U /mnt >> /mnt/etc/fstab
# Create a file
touch /mnt/root/install.sh

echo "useradd -m -g users -G wheel,storage,power,audio,video -s /usr/bin/fish $USER" >> install.sh
echo "passwd $NAME" >>install.sh
echo "sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers" >> install.sh

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
echo "sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen" >> install.sh
echo "locale-gen" >> install.sh
echo 'echo "LANG=en_US.UTF-8" >> /etc/locale.conf' >> install.sh
echo "ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime" >> install.sh
echo "hwclock --systohc" >> install.sh

echo 'echo "HOST" > /etc/hostname' >> install.sh
echo '
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	{$HOST}.localdomain	{$HOST}
EOF' >> install.sh
echo 'echo "-------------------------------------------------"' >> install.sh
echo 'echo "NetworkManager and bluetooth"' >>install.sh
echo 'echo "-------------------------------------------------"' >>install.sh
echo "systemctl enable NetworkManager bluetooth" >> install.sh
echo "pacman -S grub efibootmgr --noconfirm --needed" >> install.sh
echo "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager" --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile tpm" --disable-shim-lock" >> install.sh
echo "grub-mkconfig -o /boot/grub/grub.cfg" >> install.sh
echo "git clone https://github.com/Vpragadeesh/dotfiles" >> install.sh
echo "File has been created install.sh"
