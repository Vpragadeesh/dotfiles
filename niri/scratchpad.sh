#!/usr/bin/env sh

# Simple scratchpad toggle for niri (Hyprland-style scratchpad window)
# Usage: run this with a keybinding (e.g., Mod+Shift+Space)

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
STATE_FILE="$STATE_DIR/niri-scratchpad-window-id"

mkdir -p "$STATE_DIR"

# Get the currently focused window ID
current=$(niri msg focused-window 2>/dev/null | awk '/Window ID/ {print $3}' | tr -d ':')

# If we can't get a focused window, just exit
[ -z "$current" ] && exit 0

# Read saved scratchpad window ID (if any)
scratch=$(cat "$STATE_FILE" 2>/dev/null || true)

# Helper: check if a window ID exists in the current window list
window_exists() {
  [ -z "$1" ] && return 1
  niri msg windows 2>/dev/null | grep -q "Window ID $1:" 
}

# If we are currently focused on the scratchpad window, hide it (move it to scratchpad workspace and return to previous workspace)
if [ "$current" = "$scratch" ] && [ -n "$scratch" ]; then
  niri msg action move-window-to-workspace scratchpad 2>/dev/null
  niri msg action focus-workspace-previous 2>/dev/null
  exit 0
fi

# If we already have a saved scratchpad window and it exists, just focus it
if [ -n "$scratch" ] && window_exists "$scratch"; then
  niri msg action focus-window "$scratch" 2>/dev/null
  exit 0
fi

# Otherwise: store this window as scratchpad and hide it
printf '%s' "$current" > "$STATE_FILE"
niri msg action move-window-to-workspace scratchpad 2>/dev/null
niri msg action focus-workspace-previous 2>/dev/null

exit 0
