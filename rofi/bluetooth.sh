#!/bin/bash

THEME="$HOME/.config/rofi/glass.rasi"

# --------------------------------------------------
# Bluetooth state
# --------------------------------------------------

power=$(bluetoothctl show 2>/dev/null |
    awk '/Powered:/ {print $2; exit}')

# --------------------------------------------------
# Bluetooth OFF
# --------------------------------------------------

if [ "$power" != "yes" ]; then

    chosen=$(printf '%s\n' \
        "󰂲 Bluetooth is OFF" |
        rofi \
            -dmenu \
            -i \
            -matching fuzzy \
            -p "Bluetooth" \
            -theme "$THEME")

    [ -z "$chosen" ] && exit 0

    if [[ "$chosen" == "󰂲 Bluetooth is OFF" ]]; then

        # Remove rfkill block first
        rfkill unblock bluetooth 2>/dev/null

        # Turn Bluetooth on
        bluetoothctl power on >/dev/null 2>&1

    fi

    exit 0
fi

# --------------------------------------------------
# Bluetooth ON
# --------------------------------------------------

choices="󰂯 Bluetooth is ON"

# --------------------------------------------------
# Get paired/known devices
# --------------------------------------------------

while IFS= read -r line; do

    [ -z "$line" ] && continue

    mac=$(printf '%s\n' "$line" | awk '{print $2}')
    name=$(printf '%s\n' "$line" | cut -d' ' -f3-)

    [ -z "$mac" ] && continue
    [ -z "$name" ] && continue

    info=$(bluetoothctl info "$mac" 2>/dev/null)

    connected=$(printf '%s\n' "$info" |
        awk '/Connected:/ {print $2; exit}')

    paired=$(printf '%s\n' "$info" |
        awk '/Paired:/ {print $2; exit}')

    if [ "$connected" = "yes" ]; then

        choices="${choices}"$'\n'"󰂱 $name ✓"

    elif [ "$paired" = "yes" ]; then

        choices="${choices}"$'\n'"󰂯 $name"

    else

        choices="${choices}"$'\n'"󰂯 $name"

    fi

done < <(bluetoothctl devices 2>/dev/null)

# --------------------------------------------------
# Rofi menu
# --------------------------------------------------

chosen=$(printf '%s\n' "$choices" |
    rofi \
        -dmenu \
        -i \
        -matching fuzzy \
        -p "Bluetooth" \
        -theme "$THEME")

[ -z "$chosen" ] && exit 0

# --------------------------------------------------
# Turn Bluetooth OFF
# --------------------------------------------------

if [[ "$chosen" == "󰂯 Bluetooth is ON" ]]; then

    bluetoothctl power off >/dev/null 2>&1

    exit 0
fi

# --------------------------------------------------
# Extract device name
# --------------------------------------------------

device=$(printf '%s\n' "$chosen" |
    sed -E \
        's/^󰂱 //;
         s/^󰂯 //;
         s/ ✓$//')

[ -z "$device" ] && exit 0

# --------------------------------------------------
# Find MAC from bluetoothctl
# --------------------------------------------------

mac=""

while IFS= read -r line; do

    current_mac=$(printf '%s\n' "$line" | awk '{print $2}')
    current_name=$(printf '%s\n' "$line" | cut -d' ' -f3-)

    if [ "$current_name" = "$device" ]; then

        mac="$current_mac"
        break

    fi

done < <(bluetoothctl devices 2>/dev/null)

[ -z "$mac" ] && exit 0

# --------------------------------------------------
# Get device state
# --------------------------------------------------

info=$(bluetoothctl info "$mac" 2>/dev/null)

connected=$(printf '%s\n' "$info" |
    awk '/Connected:/ {print $2; exit}')

paired=$(printf '%s\n' "$info" |
    awk '/Paired:/ {print $2; exit}')

trusted=$(printf '%s\n' "$info" |
    awk '/Trusted:/ {print $2; exit}')

# --------------------------------------------------
# Connected -> Disconnect
# --------------------------------------------------

if [ "$connected" = "yes" ]; then

    bluetoothctl disconnect "$mac"

    exit 0
fi

# --------------------------------------------------
# Not paired -> Pair
# --------------------------------------------------

if [ "$paired" != "yes" ]; then

    # Enable authentication agent
    bluetoothctl agent on >/dev/null 2>&1
    bluetoothctl default-agent >/dev/null 2>&1

    # Pair device
    bluetoothctl pair "$mac"

    # Trust device after successful pairing
    bluetoothctl trust "$mac" >/dev/null 2>&1

fi

# --------------------------------------------------
# Connect
# --------------------------------------------------

bluetoothctl connect "$mac"
