#!/bin/bash

# Wrapper around run.sh that restarts the dashboard if it closes.
# Useful for kiosk deployments where the dashboard should always be running.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while true; do
    echo "Starting Smart Dashboard..."
    "$SCRIPT_DIR/run.sh"
    
    EXIT_CODE=$?
    echo "Dashboard exited (code: $EXIT_CODE). Restarting in 3 seconds..."
    echo "Press Ctrl+C to stop."
    
    sleep 3
done