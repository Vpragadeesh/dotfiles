#!/bin/bash

DEVICE_MAC="00:11:22:33:44:55"  # Replace with your device's MAC address

dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties'" |
while read -r line; do
    if echo "$line" | grep -q "$DEVICE_MAC" && echo "$line" | grep -q "Connected" && echo "$line" | grep -q "true"; then
        # Device connected
        playerctl pause
    fi
done
