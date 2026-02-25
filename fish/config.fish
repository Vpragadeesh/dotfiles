oh-my-posh init fish --config /usr/share/oh-my-posh/themes/montys.omp.json | source
# Auto-start Niri only on TTY1 and prefer the integrated GPU
if test -z "$DISPLAY"; and string match -q "/dev/tty1" (tty)
    # detect first DRM card whose vendor is NOT NVIDIA (0x10de) and export it
    set -l igpu ''
    for d in /sys/class/drm/card*
        if test -f "$d/device/vendor"
            set -l v (string trim (cat $d/device/vendor))
            if test "$v" != "0x10de"
                set igpu (basename $d)
                break
            end
        end
    end

    if test -n "$igpu"
        set -x WLR_DRM_DEVICES /dev/dri/$igpu
        echo "Starting niri on device /dev/dri/$igpu"
    else
        echo "Warning: could not detect non-NVIDIA DRM card — starting niri with default device"
    end

    exec dbus-run-session niri
    # export XDG_SESSION_TYPE=wayland
    # export XDG_CURRENT_DESKTOP=niri
    # export XDG_SESSION_DESKTOP=niri
    # exec niri
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
set -x PYTORCH_CUDA_ALLOC_CONF expandable_segments:True
source ~/base/bin/activate.fish
set -x NEXT_DISABLE_DEV_SSR true
zoxide init fish | source
alias c="clear"
alias e="exit"
alias f="fastfetch"
alias cf="c && f"
alias np="nvim ./ex.py"
alias n="nvim"
alias v="vim"
alias nf="nvim ~/.config/fish/config.fish"
alias gl="git clone "
alias lg="lazygit && echo 'take a backup.7z'"
alias rd="sudo pacman -Rdd "
alias cdd="cd && cd Documents"
alias cdw="cd && cd Downloads"
alias me="sudo pacman -Syu --noconfirm && yay -Syu --noconfirm && sudo pacman -Scc --noconfirm && yay -Scc --noconfirm && clear && fastfetch"
alias p="python3"
alias nano="sudo nvim"
alias nx="cdd && nvim ex.py"
alias gpu="wezterm start nvtop & wezterm start watch -n 0.5 nvidia-smi & exit"
alias dg="nvidia-smi"
alias ig="sudo intel_gpu_top"
alias h="history"
alias re="sudo reboot"
alias ls="lsd -la"
alias rswap="sudo swapoff /dev/zram0 && sudo swapon /dev/zram0"
alias :q="exit"
alias co="code --disable-gpu . && exit"
alias ..="cd .."
alias s="yay --noconfirm -S"
alias g="g -i"
alias r="yay -Rns"
alias :x="exit"
alias t="erd ."
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
alias gs="git status"
alias brd="bun run dev"
alias u="uv pip install"
alias crm="./crm.sh"
alias sp="sudo pkill "
alias run="npx react-native run-android --deviceId fijfn7danbibmvto"
# alias torrent="cd ~/extra/torrent-downloader/ && source .venv/bin/activate.fish && python3 ex.py"
alias ae="antigravity . && exit"
alias torrent="cd ~/extra/torrent-downloader/ && ./fastdown --magnet "
alias net="cd ~/extra/net/  && ./net"
alias ble="sudo systemctl start bluetooth"
# function
# ai-crm-assistant
function ai-crm-assistant
    set archive_file (ls *.7z 2>/dev/null | head -n 1)
    if test -z "$archive_file"
        echo "No .7z file found in the current directory."
        return 1
    end

    set timestamp (date "+%d-%m-%y-%H-%M")
    mv "$archive_file" ~/back-up/ai-crm-assistant/$timestamp.7z
end
set -Ux ANDROID_HOME /home/pragadeesh/Android/Sdk
set -Ux ANDROID_SDK_ROOT /home/pragadeesh/Android/Sdk
set -Ux PATH $PATH /home/pragadeesh/Android/Sdk/cmdline-tools/latest/bin /home/pragadeesh/Android/Sdk/platform-tools
set -x GOOGLE_API_KEY "AIzaSyB-lAqyix3zCN4LbGNldpe_UjE5fAALZCc"
set -x GEMINI_API_TOKEN $GOOGLE_API_KEY

# opencode
fish_add_path /home/pragadeesh/.opencode/bin
# starship init fish | source

# pnpm
set -gx PNPM_HOME "/home/pragadeesh/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
set -x PATH $PATH /home/pragadeesh/Android/Sdk/cmdline-tools/bin
set -Ux fish_user_paths $fish_user_paths (go env GOPATH)/bin
set -x ANDROID_HOME $HOME/Android/Sdk
set -x PATH $PATH $ANDROID_HOME/emulator
set -x PATH $PATH $ANDROID_HOME/platform-tools
set -x PATH $PATH $ANDROID_HOME/cmdline-tools/latest/bin
clear
fastfetch
