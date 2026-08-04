#!/bin/bash

# Set PATH explicitly (critical for autostart)
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$HOME/bin"

# Get the absolute directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to that directory
cd "$SCRIPT_DIR"

# --- BACKGROUNDS: Auto-generate backgrounds.json ---

BACKGROUNDS_DIR="$SCRIPT_DIR/static/backgrounds"
BACKGROUNDS_JSON="$SCRIPT_DIR/backgrounds.json"

if [ -d "$BACKGROUNDS_DIR" ]; then
    echo "Scanning $BACKGROUNDS_DIR for background images..."
    
    # Build JSON array from image files
    IMAGES=$(find "$BACKGROUNDS_DIR" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) -printf '"%f",')
    
    if [ -n "$IMAGES" ]; then
        IMAGES="[${IMAGES%,}]"
        echo "$IMAGES" > "$BACKGROUNDS_JSON"
        echo "Generated backgrounds.json with $(echo $IMAGES | grep -o '"[^"]*"' | wc -l) images"
    else
        echo "No images found in $BACKGROUNDS_DIR"
        echo "[]" > "$BACKGROUNDS_JSON"
    fi
else
    echo "Warning: Directory $BACKGROUNDS_DIR does not exist"
    echo "[]" > "$BACKGROUNDS_JSON"
fi

# --- Add some startup commands ---

unclutter

xset -dpms s off


# --- CLEANUP: Stop existing instances ---

# Kill any existing 'server.py' processes
pkill -f "python.*server.py"

# Kill any existing browser instances
killall -9 brave 2>/dev/null

sleep 1

# --- STARTUP: Launch new instances ---

# Execute the Python script in the background
"$SCRIPT_DIR/venv/bin/python" "$SCRIPT_DIR/server.py" "$SCRIPT_DIR" &

sleep 3

# Launch Browser in fullscreen
/usr/bin/brave-origin-stable --app="http://127.0.0.1:8080" --kiosk --class=WebApp-Dashboard --name=WebApp-Dashboard --no-first-run --noerrdialogs --disable-context-menu