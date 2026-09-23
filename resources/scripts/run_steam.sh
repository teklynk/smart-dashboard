#!/bin/bash
echo "Killing Picom"
pkill -9 picom 2>/dev/null || true
echo "Starting Picom"
picom -b --backend xrender --vsync &

echo "Killing Steam"
killall -9 steam 2>/dev/null || true
flatpak kill com.valvesoftware.Steam 2>/dev/null || true

# Prime compositor before starting steam big picture (fixes bigpicture mode opengl rendering issues
xdotool mousemove 10 10 click 1 2>/dev/null || true
flatpak run --env=SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR=0 com.valvesoftware.Steam -bigpicture