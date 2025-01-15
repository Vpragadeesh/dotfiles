setfont ter-132b
echo "1"
pacstrap -K /mnt base linux linux-firmware sof-firmware btop nvtop fish fastfetch vim neovim
echo "2"
genfstab -U /mnt >> /mnt/etc/fstab
echo "3"
arch-chroot /mnt 
echo "4"
passwd
echo "5"
echo "Enter your user name:"
echo "6"
read name
echo "7"
useradd -m -g users -G wheel,storage,power,video,audio -s /usr/bin/fish $name
echo "8"
passwd $name
echo "9"
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.tmp
echo "10"
su - $name
echo "11"
exit
echo "12"
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
echo "13"
hwclock --systohc
echo "14"
echo "en_US.utf-8 UTF-8" >> /etc/locale.gen
echo "15"
locale-gen
echo "16"
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "17"
echo "Enter your hostname"
echo "18"
read hostname
echo "19"
echo "$hostname" >> /etc/hostname
echo "20"
echo "127.0.0.1     localhost" >> /etc/hosts
echo "21"
echo "::1           localhost" >> /etc/hosts
echo "22"
echo "127.0.1.1     $hostname.localdomain         $hostname" >> /etc/hosts
echo "23"
pacman -S grub efibootmgr dosfstools mtools
echo "24"
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
echo "25"
grub-mkconfig -o /boot/grub/grub.cfg
echo "26"
systemctl enable bluetooth
echo "27"
systemctl enable NetworkManager
echo "28"
exit
echo "29"
umount -lR /mnt
echo "30"
sudo reboot
