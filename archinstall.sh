#!/bin/bash
set -e
set -o pipefail

LOGFILE="/var/log/arch_install_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

check_network() {
    log "Checking network connectivity..."
    if ping -c 2 archlinux.org &>/dev/null; then
        log "Network connectivity: OK"
    else
        log "Network connectivity: FAILED. Please ensure you are online."
        exit 1
    fi
}

update_mirrors() {
    if command -v reflector &>/dev/null; then
        log "Updating mirror list with reflector..."
        reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist || log "Reflector failed; continuing with current mirrors."
    else
        log "Reflector not installed, skipping mirror update."
    fi
}

setup_swap() {
    read -p "Do you want to configure swap? (file/partition/no, default: file): " swap_choice
    swap_choice=${swap_choice,,}
    
    case "$swap_choice" in
        file)
            read -p "Enter swap file size (e.g., 2G): " swap_size
            log "Creating swap file of size $swap_size..."
            fallocate -l "$swap_size" /mnt/swapfile
            chmod 600 /mnt/swapfile
            mkswap /mnt/swapfile
            swapon /mnt/swapfile
            echo "/swapfile none swap defaults 0 0" >> /mnt/etc/fstab
            log "Swap file created."
            ;;
        partition)
            lsblk
            read -p "Enter swap partition (e.g., /dev/sda3): " swap_part
            log "Setting up swap on $swap_part..."
            mkswap "$swap_part"
            swapon "$swap_part"
            echo "$swap_part none swap defaults 0 0" >> /mnt/etc/fstab
            log "Swap partition activated."
            ;;
        *)
            log "No swap configured."
            ;;
    esac
}

detect_gpu() {
    log "Detecting GPU..."
    if lspci | grep -iq nvidia; then
        log "NVIDIA GPU detected."
        read -p "Install NVIDIA drivers now? (yes/no): " nvidia_choice
        if [[ "${nvidia_choice,,}" == "yes" ]]; then
            pacstrap /mnt nvidia nvidia-utils nvidia-settings --noconfirm --needed
            log "NVIDIA drivers installed."
        fi
    elif lspci | grep -Ei 'amd|ati' &>/dev/null; then
        log "AMD GPU detected."
        read -p "Install AMD drivers now? (yes/no): " amd_choice
        if [[ "${amd_choice,,}" == "yes" ]]; then
            pacstrap /mnt xf86-video-amdgpu --noconfirm --needed
            log "AMD drivers installed."
        fi
    else
        log "No dedicated GPU detected."
    fi
}

format_and_mount() {
    log "Starting partitioning..."
    lsblk
    read -p "Enter root partition (e.g., /dev/nvme0n1p2): " root_part
    read -p "Enter boot partition (e.g., /dev/nvme0n1p1): " boot_part

    # Format root
    log "Formatting $root_part as ext4..."
    mkfs.ext4 -F "$root_part"
    mount "$root_part" /mnt

    # Format and mount boot
    log "Formatting $boot_part as FAT32..."
    mkfs.fat -F32 "$boot_part"
    mkdir -p /mnt/boot
    mount "$boot_part" /mnt/boot

    # Home partition
    read -p "Create separate home partition? (yes/no): " home_choice
    if [[ "${home_choice,,}" == "yes" ]]; then
        read -p "Enter home partition (e.g., /dev/nvme0n1p3): " home_part
        read -p "Format $home_part? (yes/no): " format_home
        if [[ "${format_home,,}" == "yes" ]]; then
            mkfs.ext4 -F "$home_part"
        fi
        mkdir -p /mnt/home
        mount "$home_part" /mnt/home
    fi
}

install_base() {
    log "Installing base system..."
    pacstrap /mnt base base-devel linux linux-firmware networkmanager git fish --noconfirm --needed
    genfstab -U /mnt >> /mnt/etc/fstab
}

user_setup() {
    read -p "Enter username: " username
    read -p "Enter hostname: " hostname
    arch-chroot /mnt useradd -m -G wheel -s /bin/bash "$username"
    echo "$username ALL=(ALL) NOPASSWD:ALL" >> /mnt/etc/sudoers
    log "Set password for $username:"
    arch-chroot /mnt passwd "$username"
    echo "$hostname" > /mnt/etc/hostname
}

install_desktop() {
    local de_choice
    read -p "Install Desktop Environment? (kde/gnome/xfce/no): " de_choice
    case "${de_choice,,}" in
        kde)
            pacstrap /mnt plasma sddm konsole dolphin --noconfirm --needed
            arch-chroot /mnt systemctl enable sddm
            ;;
        gnome)
            pacstrap /mnt gnome gdm --noconfirm --needed
            arch-chroot /mnt systemctl enable gdm
            ;;
        xfce)
            pacstrap /mnt xfce4 lightdm lightdm-gtk-greeter --noconfirm --needed
            arch-chroot /mnt systemctl enable lightdm
            ;;
        *)
            log "Skipping desktop environment."
            ;;
    esac
}

install_optional_packages() {
    read -p "Install common software? (office/media/dev/tools/no): " pkg_choice
    case "${pkg_choice,,}" in
        office)
            pacstrap /mnt libreoffice-fresh --noconfirm --needed ;;
        media)
            pacstrap /mnt vlc gimp --noconfirm --needed ;;
        dev)
            pacstrap /mnt code python nodejs npm --noconfirm --needed ;;
        tools)
            pacstrap /mnt htop neofetch git --noconfirm --needed ;;
    esac

    read -p "Enter additional packages (space-separated, leave empty to skip): " custom_pkgs
    if [[ -n "$custom_pkgs" ]]; then
        pacstrap /mnt $custom_pkgs --noconfirm --needed
    fi
}

# Main Execution
check_network
update_mirrors
format_and_mount
setup_swap
install_base
detect_gpu
user_setup
install_desktop
install_optional_packages

log "Installation complete! Unmount and reboot."
umount -R /mnt
