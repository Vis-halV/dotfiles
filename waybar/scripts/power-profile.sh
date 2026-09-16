#!/bin/bash

profile=$(powerprofilesctl get)

case "$profile" in
    balanced)
        icon="󰾅"
        name="Balanced"
        ;;
    performance)
        icon="󰓅"
        name="Performance"
        ;;
    power-saver)
        icon="󰌪"
        name="Power Saver"
        ;;
    *)
        icon="󰾅"
        name="Unknown"
        ;;
esac

printf '{"text":"%s","tooltip":"%s"}\n' "$icon" "$name"
