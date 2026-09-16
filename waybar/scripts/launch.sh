#!/bin/bash

# Kill any old Waybar instance
pkill -x waybar 2>/dev/null

# Small delay so Hyprland is ready
sleep 1

# Start Waybar
waybar &
