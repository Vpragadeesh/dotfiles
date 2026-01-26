#!/usr/bin/env bash
# Wrapper to safely call hyprctl from libinput-gestures (ensures PATH)
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"

if [[ "$#" -lt 1 ]]; then
  echo "Usage: $0 <hyprctl args>"
  exit 1
fi

hyprctl "$@"
