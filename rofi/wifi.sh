#!/bin/bash

THEME="$HOME/.config/rofi/glass.rasi"

# Check NetworkManager
if ! command -v nmcli >/dev/null 2>&1; then
    exit 1
fi

wifi_state=$(nmcli radio wifi 2>/dev/null)

# Wi-Fi is OFF
if [ "$wifi_state" = "disabled" ]; then

    chosen=$(printf '%s\n' "󰤭  Wi-Fi is OFF" |
        rofi \
            -dmenu \
            -i \
            -p "Wi-Fi" \
            -theme "$THEME")

    if [ -n "$chosen" ]; then
        nmcli radio wifi on
    fi

    exit 0
fi

# Refresh Wi-Fi scan
nmcli dev wifi rescan >/dev/null 2>&1

# Give NetworkManager a moment to update the scan list
sleep 1

# Get networks
networks=$(nmcli -t -f IN-USE,SSID,SIGNAL dev wifi list 2>/dev/null |
awk -F: '
{
    inuse=$1
    ssid=$2
    signal=$3

    # Ignore empty SSIDs
    if (ssid == "")
        next

    if (signal >= 75)
        icon="󰤨"
    else if (signal >= 50)
        icon="󰤥"
    else if (signal >= 25)
        icon="󰤢"
    else
        icon="󰤟"

    connected=""

    if (inuse == "*")
        connected=" ✓"

    print icon "  " ssid "  [" signal "%]" connected
}' | sort -u)

# Menu
choices=$(printf '%s\n%s\n' \
    "󰤨 Wi-Fi is ON" \
    "$networks")

chosen=$(printf '%s\n' "$choices" |
    rofi \
        -dmenu \
        -i \
        -matching fuzzy \
        -p "Wi-Fi" \
        -theme "$THEME")

[ -z "$chosen" ] && exit 0

# Turn Wi-Fi off
if [[ "$chosen" == "󰤨 Wi-Fi is ON" ]]; then
    nmcli radio wifi off
    exit 0
fi

# Extract SSID
ssid=$(printf '%s\n' "$chosen" |
    sed -E \
        's/^󰤨  //;
         s/^󰤥  //;
         s/^󰤢  //;
         s/^󰤟  //;
         s/  \[[0-9]+%\].*$//;
         s/ ✓$//')

[ -z "$ssid" ] && exit 0

# If already connected, do nothing
active_ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null |
    awk -F: '$1 == "yes" {print $2; exit}')

if [ "$active_ssid" = "$ssid" ]; then
    exit 0
fi

# Find an existing NetworkManager connection whose name matches SSID
connection=$(nmcli -t -f NAME,TYPE connection show 2>/dev/null |
    awk -F: -v ssid="$ssid" '$1 == ssid && $2 == "802-11-wireless" {print $1; exit}')

if [ -n "$connection" ]; then

    nmcli connection up "$connection"

else

    # Connect to the Wi-Fi network.
    # If it needs a password and is not already saved,
    # NetworkManager will request it in the terminal.
    nmcli dev wifi connect "$ssid"

fi
