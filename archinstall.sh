#!/bin/bash

# Configuration Variables
HOSTNAME="archlinux"
USERNAME="user"
USER_PASSWORD="password"
ROOT_PASSWORD="rootpassword"
TIMEZONE="Asia/Kolkata"
LOCALE="en_US.UTF-8"
KEYMAP="us"
FILESYSTEM="ext4" # Options: ext4, btrfs, xfs
DESKTOP_ENVIRONMENT="gnome" # Options: gnome, plasma, xfce, none

# Colored Output
INFO="\e[32m[INFO]\e[0m"
ERROR="\e[31m[ERROR]\e[0m"
WARNING="\e[33m[WARNING]\e[0m"

# Logging
LOG_FILE="arch_install.log"
exec > >(tee -i "$LOG_FILE") 2>&1

# Error Handling
set -e

# Functions
check_root() {
  if [[ $EUID -ne 0 ]]; then
    echo -e "$ERROR This script must be run as root."
    exit 1
  fi
}

check_internet() {
  if ! ping -c 1 archlinux.org &>/dev/null; then
    echo -e "$ERROR No internet connection detected."
    exit 1
  fi
}

update_system_clock() {
  echo -e "$INFO Updating system clock..."
  timedatectl set-ntp true
}

confirm_operation() {
  read -p "$WARNING Are you sure you want to proceed? (yes/no): " confirmation
  if [[ "$confirmation" != "yes" ]]; then
    echo -e "$ERROR Operation aborted."
    exit 1
  fi
}

prompt_disk_and_partitions() {
  echo -e "$INFO Detecting available disks..."
  lsblk -d -n -o NAME,SIZE
  read -p "$INFO Enter the target disk (e.g., sda, nvme0n1): " TARGET_DISK
  TARGET_DISK="/dev/$TARGET_DISK"

  echo -e "$INFO Specify partitions for $TARGET_DISK:"
  read -p "$INFO Enter the size for /boot partition (e.g., 512M): " BOOT_SIZE
  read -p "$INFO Enter the size for swap partition (e.g., 2G): " SWAP_SIZE
}

partition_disk() {
  echo -e "$INFO Partitioning disk $TARGET_DISK..."
  confirm_operation
  parted -s "$TARGET_DISK" mklabel gpt
  parted -s "$TARGET_DISK" mkpart primary fat32 1MiB "$BOOT_SIZE"
  parted -s "$TARGET_DISK" set 1 boot on
  parted -s "$TARGET_DISK" mkpart primary linux-swap "$BOOT_SIZE" "$SWAP_SIZE"
  parted -s "$TARGET_DISK" mkpart primary "$FILESYSTEM" "$SWAP_SIZE" 100%
}

format_partitions() {
  echo -e "$INFO Formatting partitions..."
  mkfs.fat -F32 "${TARGET_DISK}1"
  mkswap "${TARGET_DISK}2"
  swapon "${TARGET_DISK}2"
  mkfs."$FILESYSTEM" "${TARGET_DISK}3"
}

mount_partitions() {
  echo -e "$INFO Mounting partitions..."
  mount "${TARGET_DISK}3" /mnt
  mkdir -p /mnt/boot
  mount "${TARGET_DISK}1" /mnt/boot
}

install_base_system() {
  echo -e "$INFO Installing base system..."
  pacstrap /mnt base base-devel linux linux-firmware networkmanager reflector
}

generate_fstab() {
  echo -e "$INFO Generating fstab..."
  genfstab -U /mnt >> /mnt/etc/fstab
}

configure_system() {
  echo -e "$INFO Configuring system in chroot..."
  arch-chroot /mnt bash <<EOF
    ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
    hwclock --systohc
    sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    echo "LANG=$LOCALE" > /etc/locale.conf
    echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
    echo "$HOSTNAME" > /etc/hostname
    cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
HOSTS
    echo "root:$ROOT_PASSWORD" | chpasswd
    useradd -m -G wheel -s /bin/bash "$USERNAME"
    echo "$USERNAME:$USER_PASSWORD" | chpasswd
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    systemctl enable NetworkManager
EOF
}

install_grub() {
  echo -e "$INFO Installing GRUB bootloader..."
  arch-chroot /mnt bash <<EOF
    pacman -S grub efibootmgr --noconfirm
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
EOF
}

install_desktop_environment() {
  if [[ "$DESKTOP_ENVIRONMENT" != "none" ]]; then
    echo -e "$INFO Installing Desktop Environment: $DESKTOP_ENVIRONMENT..."
    arch-chroot /mnt bash <<EOF
      case "$DESKTOP_ENVIRONMENT" in
        gnome)
          pacman -S gnome gnome-extra gdm --noconfirm
          systemctl enable gdm
          ;;
        plasma)
          pacman -S plasma sddm --noconfirm
          systemctl enable sddm
          ;;
        xfce)
          pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
          systemctl enable lightdm
          ;;
      esac
EOF
  fi
}

update_mirror_list() {
  echo -e "$INFO Updating mirror list..."
  reflector --country India --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
}

main() {
  check_root
  check_internet
  update_system_clock
  prompt_disk_and_partitions
  partition_disk
  format_partitions
  mount_partitions
  install_base_system
  generate_fstab
  configure_system
  install_grub
  update_mirror_list
  install_desktop_environment
  echo -e "$INFO Installation complete. You can reboot now."
}

main
