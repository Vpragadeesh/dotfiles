#!/usr/bin/env bash

setfont ter-132n
echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1)"
read EFI

echo "Please enter Root(/) paritition: (example /dev/sda3)"
read ROOT  

echo "Please enter your Username"
read USER 

echo "Enter your hostname"
read HOST

echo "Please enter your Full Name"
read NAME 

echo "Please enter your Password"
read PASSWORD 

# make filesystems
echo -e "\nCreating Filesystems...\n"

existing_fs=$(blkid -s TYPE -o value "$EFI")
if [[ "$existing_fs" != "vfat" ]]; then
    mkfs.vfat -F32 "$EFI"
fi

mkfs.ext4 "${ROOT}"

# mount target
mount "${ROOT}" /mnt
ROOT_UUID=$(blkid -s UUID -o value "$ROOT")
mount --mkdir "$EFI" /mnt/boot/efi


echo "--------------------------------------"
echo "-- INSTALLING Base Arch Linux --"
echo "--------------------------------------"
pacstrap -K /mnt base base-devel linux linux-firmware sof-firmware networkmanager vim intel-ucode bluez bluez-utils git btop nvtop  --noconfirm --needed

# fstab
genfstab -U /mnt >> /mnt/etc/fstab
# Create a file
filename="/mnt/userinstall.sh"
touch $filename
  echo "useradd -m -g users -G wheel,storage,power,audio,video -s /usr/bin/fish $USER
passwd $NAME
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i 's/^%wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

echo "-------------------------------------------------"
echo "Setup Language to US and set locale"
echo "-------------------------------------------------"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

ln -sf /usr/share/zoneinfo/Asia/Kathmandu /etc/localtime
hwclock --systohc

echo "HOST" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	{$HOST}.localdomain	{$HOST}
echo "-------------------------------------------------"
echo "NetworkManager and bluetooth"
echo "-------------------------------------------------"
systemctl enable NetworkManager bluetooth
pacman -S grub efibootmgr --noconfirm --needed
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id="Linux Boot Manager" --modules="normal test efi_gop efi_uga search echo linux all_video gfxmenu gfxterm_background gfxterm_menu gfxterm loadenv configfile tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg
git clone https://github.com/Vpragadeesh/dotfiles
" >> $filename

echo "File has been created userinstall.sh
arch-chroot /mnt
echo "you need to run userinstall.sh it will be in /home/$USER/userinstall.sh"
