#!/bin/bash

STATUS=$(nmcli radio wifi)

if [ "$STATUS" = "enabled" ]; then
    CHOICE=$(printf "󰤨  Wi-Fi ON\n󰤭  Turn Wi-Fi OFF" | rofi -dmenu -i -p "Wi-Fi")
else
    CHOICE=$(printf "󰤭  Wi-Fi OFF\n󰤨  Turn Wi-Fi ON" | rofi -dmenu -i -p "Wi-Fi")
fi

case "$CHOICE" in
    *"Turn Wi-Fi OFF"*)
        nmcli radio wifi off
        ;;
    *"Turn Wi-Fi ON"*)
        nmcli radio wifi on
        ;;
esac
