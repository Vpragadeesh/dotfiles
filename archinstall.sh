#!/bin/bash
set -e
set -o pipefail

LOGFILE="/var/log/arch_install_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

# Check for network connectivity
check_network() {
    log "Checking network connectivity..."
    if ping -c 2 archlinux.org &>/dev/null; then
        log "Network connectivity: OK"
    else
        log "Network connectivity: FAILED. Please ensure you are online."
        exit 1
    fi
}

# Update mirror list using reflector if installed
update_mirrors() {
    if command -v reflector &>/dev/null; then
        log "Updating mirror list with reflector..."
        reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist || log "Reflector failed; continuing with current mirrors."
    else
        log "Reflector not installed, skipping mirror update."
    fi
}

# Check and create a swap file if desired
setup_swapfile() {
    read -p "Do you want to create a swap file? (yes/no, default: no): " create_swap
    create_swap=${create_swap,,}
    if [[ "$create_swap" == "yes" ]]; then
        read -p "Enter swap file size (e.g., 2G): " swap_size
        log "Creating swap file of size $swap_size..."
        fallocate -l "$swap_size" /mnt/swapfile
        chmod 600 /mnt/swapfile
        mkswap /mnt/swapfile
        swapon /mnt/swapfile
        echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
        log "Swap file created."
    else
        log "No swap file created."
    fi
}

# Detect GPU type and prompt for additional drivers
detect_gpu() {
    log "Detecting GPU..."
    if lspci | grep -iq nvidia; then
        log "NVIDIA GPU detected."
        read -p "Do you want to install NVIDIA drivers now? (now/later): " nvidia_choice
        if [[ "$nvidia_choice" == "now" ]]; then
            pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
            log "NVIDIA drivers installed."
        else
            log "NVIDIA drivers installation skipped. You can install later with: pacman -S nvidia nvidia-utils nvidia-settings"
        fi
    elif lspci | grep -Ei 'amd|ati' &>/dev/null; then
        log "AMD GPU detected."
        read -p "Do you want to install AMD drivers now? (now/later): " amd_choice
        if [[ "$amd_choice" == "now" ]]; then
            pacstrap /mnt xf86-video-amdgpu --noconfirm --needed
            log "AMD drivers installed."
        else
            log "AMD drivers installation skipped. You can install later with: pacman -S xf86-video-amdgpu"
        fi
    else
        log "No NVIDIA or AMD GPU detected."
    fi
}

# Prompt for firewall installation
install_firewall() {
    read -p "Do you want to install and enable UFW (firewall)? (yes/no, default: no): " firewall_choice
    firewall_choice=${firewall_choice,,}
    if [[ "$firewall_choice" == "yes" ]]; then
        pacstrap /mnt ufw --noconfirm --needed
        arch-chroot /mnt bash -c "systemctl enable ufw && ufw default deny incoming && ufw default allow outgoing && ufw enable"
        log "UFW installed and enabled."
    else
        log "Firewall installation skipped."
    fi
}

# Option to install an AUR helper (yay) in post-installation
install_aur_helper() {
    read -p "Do you want to install an AUR helper (yay) post-install? (yes/no, default: no): " aur_choice
    aur_choice=${aur_choice,,}
    if [[ "$aur_choice" == "yes" ]]; then
        arch-chroot /mnt bash -c "sudo -u $username bash -c '
            cd /home/$username &&
            git clone https://aur.archlinux.org/yay.git &&
            cd yay &&
            makepkg -si --noconfirm
        '"
        log "AUR helper yay installed."
    else
        log "AUR helper installation skipped."
    fi
}

# Main partitioning, mounting, and installation functions
format_and_mount() {
    log "--------------------------------------------------"
    log "-- Partition Setup: Formatting and Mounting     --"
    log "--------------------------------------------------"
    read -p "Enter your root partition (e.g., /dev/sda2): " root_partition
    read -p "Enter your boot partition (e.g., /dev/sda1): " boot_partition

    log "Formatting root partition ($root_partition) as ext4..."
    mkfs.ext4 "$root_partition"
    log "Formatting boot partition ($boot_partition) as FAT32..."
    mkfs.fat -F32 "$boot_partition"
    log "Mounting root partition to /mnt..."
    mount "$root_partition" /mnt
    log "Creating /mnt/boot and mounting boot partition..."
    mkdir -p /mnt/boot
    mount "$boot_partition" /mnt/boot

    # New: Ask for separate home partition
    read -p "Do you want to use a separate home partition? (yes/no, default: no): " home_choice
    home_choice=${home_choice,,}
    if [[ "$home_choice" == "yes" ]]; then
        read -p "Enter your home partition (e.g., /dev/sda3): " home_partition
        log "Formatting home partition ($home_partition) as ext4..."
        mkfs.ext4 "$home_partition"
        log "Mounting home partition to /mnt/home..."
        mkdir -p /mnt/home
        mount "$home_partition" /mnt/home
        log "Home partition formatted and mounted."
    else
        log "No separate home partition selected. Using /mnt as home."
    fi

    log "Partitions formatted and mounted successfully."
    log "Please ensure everything is set to /mnt, /mnt/boot, and optionally /mnt/home."
}

update_keyring() {
    log "Updating Archlinux-keyring..."
    pacman -Sy archlinux-keyring --noconfirm
}

install_base() {
    log "--------------------------------------"
    log "-- INSTALLING Base Arch Linux       --"
    log "--------------------------------------"

    read -p "Is your CPU AMD or Intel? (Default: Intel) " cpu_type
    cpu_type=${cpu_type,,}  # convert to lowercase
    if [[ "$cpu_type" != "amd" && "$cpu_type" != "intel" ]]; then
        log "Invalid CPU type. Defaulting to Intel."
        cpu_type="intel"
    fi

    base_packages=(base base-devel linux linux-firmware sof-firmware networkmanager neovim bluez bluez-utils git fish bash)
    if [[ "$cpu_type" == "intel" ]]; then
        base_packages+=(intel-ucode)
    else
        base_packages+=(amd-ucode)
    fi

    pacstrap /mnt "${base_packages[@]}" --noconfirm --needed
    log "Base packages installed."

    log "Generating fstab..."
    genfstab -U /mnt >> /mnt/etc/fstab
}

# New: Optional installation of additional packages
install_additional_packages() {
    read -p "Do you want to install additional packages? (yes/no, default: no): " add_pkg_choice
    add_pkg_choice=${add_pkg_choice,,}
    if [[ "$add_pkg_choice" == "yes" ]]; then
        read -p "Enter additional packages (space-separated): " additional_packages
        if [[ -n "$additional_packages" ]]; then
            log "Installing additional packages: $additional_packages..."
            pacstrap /mnt $additional_packages --noconfirm --needed
            log "Additional packages installed."
        else
            log "No additional packages specified."
        fi
    else
        log "Skipping additional package installation."
    fi
}

user_setup() {
    read -p "Enter username (default: user): " username
    username=${username:-user}
    read -p "Enter full name (default: User Name): " fullname
    fullname=${fullname:-"User Name"}
    read -s -p "Enter password for user $username: " userpassword
    echo
    read -p "Enter hostname (default: arch-linux): " hostname
    hostname=${hostname:-arch-linux}
    read -p "Enter the default shell for the user (default: /usr/bin/fish): " usershell
    usershell=${usershell:-/usr/bin/fish}
}

write_postinstall_script() {
    cat <<EOF > /mnt/next.sh
#!/bin/bash
set -e
set -o pipefail

# User setup
useradd -m -s "$usershell" "$username"
usermod -c "$fullname" "$username"
usermod -aG wheel,storage,power,audio,video "$username"
echo "$username:$userpassword" | chpasswd

# Enable sudo for wheel group (NOPASSWD for simplicity)
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Locale and timezone setup
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc

# Hostname and networking setup
echo "$hostname" > /etc/hostname
cat <<HOSTS > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $hostname.localdomain  $hostname
HOSTS

systemctl enable NetworkManager bluetooth

# Bootloader installation
read -p "Do you want to install GRUB or systemd-boot? (Default: systemd-boot) " bootloader
bootloader=\${bootloader,,}
if [[ "\$bootloader" != "grub" && "\$bootloader" != "systemd-boot" ]]; then
    echo "Invalid bootloader choice. Defaulting to systemd-boot."
    bootloader="systemd-boot"
fi

if [[ "\$bootloader" == "grub" ]]; then
    pacman -S grub efibootmgr --noconfirm --needed
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id="Linux Boot Manager"
    grub-mkconfig -o /boot/grub/grub.cfg
else
    bootctl install
    cat <<LOADER > /boot/loader/loader.conf
default arch
timeout 5
editor 0
LOADER
    root_uuid=\$(blkid -s UUID -o value \$(findmnt -n -o SOURCE /))
    cat <<ENTRY > /boot/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=\$root_uuid rw
ENTRY
fi

# Desktop Environment installation
read -p "Do you want to install a Desktop Environment? (Default: no) " install_de
install_de=\${install_de:-no}
if [[ "\$install_de" == "yes" ]]; then
    read -p "Choose Desktop Environment (Hyprland/KDE/GNOME, Default: KDE): " de
    de=\${de:-kde}
    case "\$de" in
        hyprland)
            pacman -S hyprland waybar rofi wofi alacritty grim slurp xdg-desktop-portal-hyprland --noconfirm --needed
            ;;
        kde)
            pacman -S plasma kde-applications sddm --noconfirm --needed
            systemctl enable sddm
            ;;
        gnome)
            pacman -S gnome gnome-tweaks gdm --noconfirm --needed
            systemctl enable gdm
            ;;
        *)
            echo "Invalid choice. Skipping DE installation."
            ;;
    esac
fi

log() {
    echo "[\$(date '+%Y-%m-%d %H:%M:%S')] \$*" >> /root/next.log
}

log "Post-installation tasks completed. Installation Complete! You may now reboot."
EOF
    chmod +x /mnt/next.sh
}

# Main execution starts here
log "Starting Arch Linux installation script."
check_network
update_mirrors
format_and_mount
update_keyring
install_base
install_additional_packages
user_setup
# Optional: Setup swap file
setup_swapfile

# Install base system for NVIDIA/AMD detection & optional drivers
detect_gpu

# Write post-install script
write_postinstall_script

# Optionally prompt for firewall installation (will run in post-chroot)
install_firewall

# Make script executable and run chroot script
chmod +x /mnt/next.sh
log "Entering chroot to continue setup..."
arch-chroot /mnt bash /next.sh

# After chroot script finishes, prompt to install AUR helper
install_aur_helper

log "Installation process complete. Please reboot your system."
