oh-my-posh init fish --config ~/.poshthemes/montys.omp.json | source
if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
    exec Hyprland
end
export GTK_THEME=Adwaita:dark
alias c="clear"
alias e="exit"
alias f="fastfetch --logo arcolinux"
alias cf="c && f"
alias n="nvim"
alias nz="nvim ~/.zshrc"
alias gl="git clone "
alias s="sudo pacman -S --noconfirm"
alias r="sudo pacman -Rns --noconfirm"
alias rd="sudo pacman -Rdd "
alias cdd="cd && cd Documents"
alias cdw="cd && cd Downloads"
alias u="sudo pacman -Syu --noconfirm&& yay -Syu --noconfirm"
alias me="u && sc && cf"
alias sc="sudo pacman -Scc && yay -Scc"
alias p="python3"
alias all="source all/bin/activate.fish"
alias nx="cdd && nvim ex.py"
alias gpu="wezterm start nvtop & wezterm start watch -n 0.5 nvidia-smi & exit"
alias dg="nvidia-smi"
alias ig="sudo intel_gpu_top"
alias h="history"
alias re="sudo reboot now"
alias ls="lsd -a"
alias rswap="sudo swapoff /dev/nvme0n1p4 && sudo swapon /dev/nvme0n1p4"
alias :q="exit"
alias co="code"
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
zoxide init fish | source
export OLLAMA_HOST=127.0.0.1
alias ty="ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1 "
alias cache="find ~/.cache -mindepth 1 -maxdepth 1 ! -name "oss.krtirtho.spotube" -exec rm -rf {} \;"
alias ng="cdd && n ex.go"
alias hsoff="nmcli connection down Hotspot"
alias nr="cdd && nvim ex.rs"
# Kubernetes completions
# kubectl completion fish | source
#
# # Minikube completion
# minikube completion fish | source

# Useful aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kgn='kubectl get nodes'
alias kga='kubectl get all'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'

# Minikube shortcuts
alias mk='minikube'
alias mkstart='minikube start'
alias mkstop='minikube stop'
alias mkstatus='minikube status'
alias mkdash='minikube dashboard'
set -gx PATH $PATH /opt/cuda/bin  # ✅ Appends to existing PATH
ulimit -n 4096
set -Ux PYENV_ROOT $HOME/.pyenv
set -Ux PATH $PYENV_ROOT/bin $PATH
set -x VKD3D_FEATURE_LEVEL 12_1
pyenv init --path | source
pyenv init - | source
set -gx TERMINFO /usr/share/terminfo
set -x GEMINI_API_KEY "AIzaSyAVgJLqfnfR3hvK3DZFdv04pjHxxJOa4Z8"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/miniconda3/bin/conda
    eval /opt/miniconda3/bin/conda "shell.fish" "hook" $argv | source
else
    if test -f "/opt/miniconda3/etc/fish/conf.d/conda.fish"
        . "/opt/miniconda3/etc/fish/conf.d/conda.fish"
    else
        set -x PATH "/opt/miniconda3/bin" $PATH
    end
end
# <<< conda initialize <<<

conda activate base

# pnpm
set -gx PNPM_HOME "/home/pragadeesh/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
