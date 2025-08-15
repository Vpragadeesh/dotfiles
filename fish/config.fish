oh-my-posh init fish --config /usr/share/oh-my-posh/themes/montys.omp.json | source
# Auto-start X only on TTY1
if test -z "$DISPLAY"; and string match -q "/dev/tty1" (tty)
    exec hyprland
end
export GTK_THEME=Breeze-Dark
set -x QT_QPA_PLATFORMTHEME qt5ct
set -x QT_QPA_PLATFORMTHEME qt6ct
set -x QT_STYLE_OVERRIDE breeze
set -gx PYENV_ROOT $HOME/.pyenv
set -gx PNPM_HOME "/home/pragadeesh/.local/share/pnpm"
set -gx PATH /opt/cuda/bin $PYENV_ROOT/bin $PNPM_HOME $PATH
ulimit -n 4096
set -x VKD3D_FEATURE_LEVEL 12_1
set -gx TERMINFO /usr/share/terminfo
set -x OLLAMA_HOST 127.0.0.1
source ~/base/bin/activate.fish
set -x NEXT_DISABLE_DEV_SSR true
zoxide init fish | source
alias c="clear"
alias e="exit"
alias f="fastfetch --logo alpine"
alias cf="c && f"
alias n="nvim"
alias v="vim"
alias nf="nvim ~/.config/fish/config.fish"
alias gl="git clone "
alias lg="lazygit"
alias s="sudo pacman -S --noconfirm"
alias r="sudo pacman -Rns --noconfirm"
alias rd="sudo pacman -Rdd "
alias cdd="cd && cd Documents"
alias cdw="cd && cd Downloads"
alias me="sudo pacman -Syu --noconfirm && yay -Syu --noconfirm && sudo pacman -Scc && yay -Scc && clear && fastfetch --logo alpine"
alias p="python3"
alias nx="cdd && nvim ex.py"
alias gpu="wezterm start nvtop & wezterm start watch -n 0.5 nvidia-smi & exit"
alias dg="nvidia-smi"
alias ig="sudo intel_gpu_top"
alias h="history"
alias re="sudo reboot"
alias ls="lsd -a"
alias rswap="sudo swapoff /dev/nvme0n1p4 && sudo swapon /dev/nvme0n1p4"
alias :q="exit"
alias co="code . && exit"
alias ..="cd .."
alias ys="yay -S --noconfirm "
alias g="g -i"
alias yr="yay -Rns"
alias :x="exit"
alias t="tree"
alias nv="nvim"
alias nvi="nvim"
alias q="exit"
alias clo="tty-clock -c -s"
alias cloy="tty-clock -c -s -C 3"
alias ncx="cdd && n ex.c++"
alias hscnt="iw dev wlp0s20f3 station dump | grep 'Station' | wc -l"
alias hslist="sudo nbtscan 10.42.0.0/24"
alias cd="z"
alias ty="ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1 "
alias ng="cdd && n ex.go"
alias hsoff="nmcli connection down Hotspot"
alias nr="cdd && nvim ex.rs"
alias dls="docker ps -a"
alias gp="git pull"
alias prd="pnpm run dev"
alias u="uv pip install"
alias si="source image-upscaling/bin/activate.fish"
