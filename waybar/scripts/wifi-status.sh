#!/bin/bash

wifi=$(nmcli radio wifi 2>/dev/null)

if [ "$wifi" != "enabled" ]; then
    printf '{"text":"󰤭","tooltip":"Wi-Fi\\nDisabled\\n\\nClick to open Wi-Fi menu","class":"disabled"}\n'
    exit 0
fi

ssid=$(nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | grep '^yes:' | head -n1 | cut -d: -f2-)

if [ -z "$ssid" ]; then
    printf '{"text":"󰤭","tooltip":"Wi-Fi\\nDisconnected\\n\\nClick to open Wi-Fi menu","class":"disconnected"}\n'
    exit 0
fi

iface=$(nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep ':wifi:connected' | head -n1 | cut -d: -f1)

if [ -z "$iface" ]; then
    printf '{"text":"󰤨","tooltip":"Wi-Fi\\nNetwork: %s\\nConnected","class":"connected"}\n' "$ssid"
    exit 0
fi

rx1=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null)
tx1=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null)

sleep 1

rx2=$(cat /sys/class/net/"$iface"/statistics/rx_bytes 2>/dev/null)
tx2=$(cat /sys/class/net/"$iface"/statistics/tx_bytes 2>/dev/null)

download=$(awk -v a="$rx1" -v b="$rx2" 'BEGIN {printf "%.1f", (b-a)*8/1000000}')
upload=$(awk -v a="$tx1" -v b="$tx2" 'BEGIN {printf "%.1f", (b-a)*8/1000000}')

signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\*:' | head -n1 | cut -d: -f2)

printf '{"text":"󰤨","tooltip":"Wi-Fi\\nNetwork: %s\\nSignal: %s%%\\n\\n↓ Download: %s Mbps\\n↑ Upload: %s Mbps\\n\\nClick to open Wi-Fi menu","class":"connected"}\n' "$ssid" "${signal:-Unknown}" "$download" "$upload"
