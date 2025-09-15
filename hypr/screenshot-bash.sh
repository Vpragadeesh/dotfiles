#!/bin/bash

# File path (optional: still save in Pictures)
f="$HOME/Pictures/screenshot-$(date +%F--%H-%M-%S).png"

# Take selected area screenshot
grim -g "$(slurp)" "$f"

# Copy to clipboard
wl-copy --type image/png < "$f"

# Notification
notify-send "📸 Screenshot Copied to Clipboard" "$f"
