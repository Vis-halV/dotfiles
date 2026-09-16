#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
STATE_FILE="$HOME/.cache/awww/current_wallpaper"

WALLPAPERS=(
    "$WALLPAPER_DIR/01.jpg"
    "$WALLPAPER_DIR/02.jpeg"
    "$WALLPAPER_DIR/03.png"
)

# Create state directory
mkdir -p "$(dirname "$STATE_FILE")"

# Read current wallpaper index
if [ -f "$STATE_FILE" ]; then
    CURRENT=$(cat "$STATE_FILE")
else
    CURRENT=0
fi

# Move to the next wallpaper
NEXT=$(( (CURRENT + 1) % ${#WALLPAPERS[@]} ))

# Set wallpaper
awww img "${WALLPAPERS[$NEXT]}" \
    --transition-type fade \
    --transition-duration 1 \
    >/dev/null 2>&1

# Save current index
echo "$NEXT" > "$STATE_FILE"
