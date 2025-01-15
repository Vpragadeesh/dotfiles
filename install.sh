setfont ter-132b
pacstrap -K /mnt base linux linux-firmware sof-firmware btop nvtop fish fastfetch vim neovim 
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt 
passwd
echo "Enter your user name:"
read name
useradd -m -g users -G wheel,storage,power,video,audio -s /usr/bin/fish $name
passwd $name
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers.tmp
su - $name
exit
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.utf-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "Enter your hostname"
read hostname
echo "$hostname" >> /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     $hostname.localdomain         $hostname" >> /etc/hosts
pacman -S grub efibootmgr dosfstools mtools
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable bluetooth
systemctl enable NetworkManager
exit
umount -lR /mnt

sudo reboot
