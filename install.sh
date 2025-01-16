setfont ter-132b
pacstrap -K /mnt base linux linux-firmware sof-firmware btop nvtop fish fastfetch vim neovim
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt 
umount -lR /mnt
#sudo reboot
