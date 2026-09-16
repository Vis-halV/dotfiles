#!/bin/bash

THEME="$HOME/.config/rofi/glass.rasi"

# Make sure PulseAudio/PipeWire Pulse is available
if ! pactl info >/dev/null 2>&1; then
    exit 1
fi

# Current volume
volume=$(pactl get-sink-volume @DEFAULT_SINK@ |
    grep -o '[0-9]\+%' |
    head -1)

# Current mute state
mute=$(pactl get-sink-mute @DEFAULT_SINK@ |
    awk '{print $2}')

if [ "$mute" = "yes" ]; then
    volume_icon="󰖁"
    volume_text="Muted"
else
    volume_icon="󰕾"
    volume_text="$volume"
fi

# Current output sink
sink=$(pactl get-default-sink)

# Get sink description safely
sink_name=$(pactl list sinks |
    awk -v sink="$sink" '
        $1 == "Name:" {
            in_sink = ($2 == sink)
        }

        in_sink && $1 == "Description:" {
            sub(/^Description:[[:space:]]*/, "")
            print
            exit
        }
    ')

[ -z "$sink_name" ] && sink_name="$sink"

# Menu
choices=$(printf '%s\n' \
    "$volume_icon Volume: $volume_text" \
    "󰖁 Toggle mute" \
    "󰕿 Volume -" \
    "󰕾 Volume +" \
    "󰓃 $sink_name")

chosen=$(printf '%s\n' "$choices" |
    rofi \
        -dmenu \
        -i \
        -p "Audio" \
        -theme "$THEME")

[ -z "$chosen" ] && exit 0

case "$chosen" in

    *"Toggle mute"*)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;

    *"Volume -"*)
        pactl set-sink-volume @DEFAULT_SINK@ -5%
        ;;

    *"Volume +"*)
        pactl set-sink-volume @DEFAULT_SINK@ +5%
        ;;

    *"Volume:"*)
        if command -v pavucontrol >/dev/null 2>&1; then
            pavucontrol
        fi
        ;;

    *"$sink_name"*)
        if command -v pavucontrol >/dev/null 2>&1; then
            pavucontrol
        fi
        ;;

esac
