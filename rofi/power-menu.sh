#!/bin/bash

chosen=$(printf '%s\n' \
    '  Lock' \
    '󰤄  Suspend' \
    '󰜉  Reboot' \
    '  Shutdown' \
    '󰍃  Logout' |
    rofi -dmenu \
        -i \
        -p '' \
        -theme ~/.config/rofi/power.rasi)

case "$chosen" in
    *"Lock")
        hyprlock
        ;;
    *"Suspend")
        systemctl suspend
        ;;
    *"Reboot")
        systemctl reboot
        ;;
    *"Shutdown")
        systemctl poweroff
        ;;
    *"Logout")
        uwsm stop
        ;;
esac
