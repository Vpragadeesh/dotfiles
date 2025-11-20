#!/bin/sh
# Enable tap-to-click and natural scrolling for common X input drivers.

set -e

# Try to find a touchpad/trackpad device name
DEV=$(xinput --list --name-only | grep -iE 'touchpad|trackpad' | head -n1)

if [ -z "$DEV" ]; then
  DEV=$(xinput --list | grep -iE 'touchpad|trackpad' | sed -n '1p' | sed -E 's/.*\"(.*)\".*/\1/')
fi

if [ -z "$DEV" ]; then
  echo "[touchpad_setup] No touchpad/trackpad found via xinput. Exiting."
  exit 0
fi

# Helper to try setting a property by name (ignore failures)
set_prop() {
  local dev="$1"
  local prop="$2"
  local val="$3"
  if xinput list-props "$dev" | grep -Fq "$prop"; then
    xinput set-prop "$dev" "$prop" $val || true
  fi
}

# Enable libinput tapping (tap-to-click) if available
set_prop "$DEV" "libinput Tapping Enabled" 1
# Enable natural scrolling if available
set_prop "$DEV" "libinput Natural Scrolling Enabled" 1
# Synaptics fallback
set_prop "$DEV" "Synaptics Tap Action" 2

# Confirm values
echo "[touchpad_setup] Device: $DEV"
xinput list-props "$DEV" | grep -E "Tapping|Natural|Synaptics" || true

exit 0
