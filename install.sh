setfont ter-132b
pacstrap -i /mnt base linux linux-firmware sof-firmware btop nvtop 
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "Enter your Hostname:"
read hostname
echo "$hostname" >> /etc/hostname
