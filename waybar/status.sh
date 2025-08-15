#!/bin/bash

# Network speeds & IP
NET_DOWN=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd+ - | bc)
NET_UP=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd+ - | bc)
sleep 1
NET_DOWN_NEW=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | paste -sd+ - | bc)
NET_UP_NEW=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | paste -sd+ - | bc)
DOWN_RATE=$(( (NET_DOWN_NEW - NET_DOWN) / 1024 ))
UP_RATE=$(( (NET_UP_NEW - NET_UP) / 1024 ))
IP_ADDR=$(ip addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | grep -v 127.0.0.1 | head -n 1)

# CPU usage
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | awk '{printf "%.1f", $1}')

# Memory
MEM_USED=$(free -h | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -h | awk '/Mem:/ {print $2}')

# GPU usage (NVIDIA example)
if command -v nvidia-smi &> /dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader,nounits | awk -F', ' '{printf "%s%% - %s MiB", $1, $2}')
else
    GPU_INFO="N/A"
fi

# Volume
VOL=$(pamixer --get-volume 2>/dev/null || echo "0")

# Brightness
BRI=$(brightnessctl get 2>/dev/null | awk '{print int($1/255*100)}')

# Battery capacity & health
BAT_CAP=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n 1)
BAT_HEALTH=$(cat /sys/class/power_supply/BAT*/energy_full 2>/dev/null | head -n 1)
BAT_DESIGN=$(cat /sys/class/power_supply/BAT*/energy_full_design 2>/dev/null | head -n 1)
if [[ -n "$BAT_HEALTH" && -n "$BAT_DESIGN" ]]; then
    HEALTH=$(awk "BEGIN {print ($BAT_HEALTH/$BAT_DESIGN)*100}")
else
    HEALTH="N/A"
fi

# Date & time
DATE=$(date "+%d-%m-%y ( %a )   %H:%M:%S")

# Output in Waybar JSON format
echo "{\"text\": \" ${DOWN_RATE}KB/s/  ${UP_RATE}KB/s • ${IP_ADDR}   ${CPU_USAGE}%    ${MEM_USED} • ${MEM_TOTAL}    ${GPU_INFO}    ${VOL}%    ${BRI}%  󰂀 ${BAT_CAP}% (${HEALTH:0:4}% health)  ${DATE}     \", \"class\": \"status\"}"
