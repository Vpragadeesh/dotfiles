#!/bin/bash

# Folder containing wallpapers
WALLPAPER_DIR="$HOME/Wallpaper-Bank/"

# Time interval (in seconds)
# 5 minutes
INTERVAL=1

# Start daemon if not already running
pgrep -x swww-daemon > /dev/null || swww-daemon &

while true; do
    # Pick a random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

    # Set wallpaper with transition
    swww img "$WALLPAPER" --transition-type any --transition-duration 2

    sleep $INTERVAL
done