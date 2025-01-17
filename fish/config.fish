# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# if test -f /home/pragadeesh/miniconda3/bin/conda
#     eval /home/pragadeesh/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# else
#     if test -f "/home/pragadeesh/miniconda3/etc/fish/conf.d/conda.fish"
#         . "/home/pragadeesh/miniconda3/etc/fish/conf.d/conda.fish"
#     else
#         set -x PATH "/home/pragadeesh/miniconda3/bin" $PATH
#     end
# end
#
#oh-my-posh init fish --config ~/.poshthemes/ | source

if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
    exec Hyprland
end

set -x LD_LIBRARY_PATH /home/pragadeesh/.local/lib/arch-mojo $LD_LIBRARY_PATH
set -gx PATH ~/miniconda3/bin $PATH
alias c="clear"
alias e="exit"
alias f="fastfetch --logo arcolinux"
alias ff="fastfetch --logo fedora"
alias cf="c && f"
alias cff="c && ff"
alias n="nvim"
alias nz="nvim ~/.zshrc"
alias gl="git clone "
alias s="sudo pacman -S"
alias r="sudo pacman -Rns "
alias rd="sudo pacman -Rdd "
alias cdd="cd && cd Documents"
alias cdw="cd && cd Downloads"
alias sc="sudo pacman -Scc"
alias yc="sudo yay -Scc"
alias u="sudo pacman -Syu --noconfirm&& yay -Syu --noconfirm"
alias me="rm -rf ~/.cache/* && u && sc && yc && cf"
alias mee="rm -rf ~/.cache/* && u && sc && yc && cf && exit"
alias p="python3"
alias all="source all/bin/activate.fish"
alias nx="cdd && nvim ex.py"
alias gpu="wezterm start nvtop & wezterm start watch -n 0.5 nvidia-smi"
alias shut="shutdown now"
alias dg="nvidia-smi"
alias ig="sudo intel_gpu_top"
alias h="history"
alias re="sudo reboot now"
alias mes="me && x"
alias lh="lsd -a"
alias ls="lsd"
alias pr="paru -Rns "
alias cs="rm -rf ~/.cache/* && sc&& gdu /"
alias rswap="sudo swapoff -a && sudo swapon -a"
alias hotspoton="nmcli dev wifi hotspot ifname wlp0s20f3 ssid hotspot password 12345678"
alias hotspotoff="nmcli dev disconnect ifname wlp0s20f3"
alias :q="exit"
alias mf="fastfetch -l openbsd"
alias batteryc="upower -i /org/freedesktop/UPower/devices/battery_BAT1"
alias :Q="exit"
alias ..="cd .."
alias ys="yay -S "
alias g="g -i"
alias vpn="cd /home/archlinux/Downloads/vpnbook-openvpn-us16/ && sudo openvpn vpnbook-us16-udp25000.ovpn"
alias yr="yay -Rns"
alias data="p /home/archlinux/Documents/dataset/dataset.py"
alias kivi="cdd && cd KiVi_2.0"
alias :x="exit"
alias t="tree"
alias cl="sudo pacman -R $(pacman -Qdtq) --noconfirm"
alias yolo="cdd && cd yolo"
alias nv="nvim"
alias nvi="nvim"
alias ny="yolo && n yolo.py"
alias q="exit"
alias na="cd /home/pragadeesh/Documents/flask/ && n app.py"
alias a="python /home/archlinux/Documents/app.py"
alias os="cd /home/pragadeesh/Documents/sub/os/"
alias fl="cd /home/pragadeesh/Documents/sub/fl/"
alias ml="cd /home/pragadeesh/Documents/sub/ml/"
alias ppp="cd /home/pragadeesh/Documents/sub/ppp/"
alias all="source all/bin/activate.fish"
zoxide init fish | source
alias cd="z"
