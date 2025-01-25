sudo pacman -S hyprland nvidia nvidia-utils waybar go lsd w3m npm nvtop btop fish fzf fd bash hostapd dnsmasq rofi 
cd /home/pragadeesh/
mkdir ex
mv -r ~/dotfiles/ ~/ex/
git clone https://github.com/Vpragadeesh/dotfiles
mkdir -p /home/pragadeesh/.config/hypr/
mkdir -p /home/pragadeesh/.config/fish/
mkdir -p /home/pragadeesh/.config/waybar/
mkdir -p /home/pragadeesh/.config/nvim/
mkdir -p /home/pragadeesh/.config/rofi/

cp -r ~/dotfiles/hypr/ ~/.config/hypr/
cp -r ~/dotfiles/fish/ ~/.config/fish/
cp -r ~/dotfiles/nvim/ ~/.config/nvim/
cp -r ~/dotfiles/rofi/ ~/.config/rofi/
cp -r ~/dotfiles/waybar/ ~/.config/waybar/

echo "install yay"
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
sudo nvim /etc/systemd/system/getty@tty1.service.d/override.conf

