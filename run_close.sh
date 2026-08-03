#!/bin/bash

# Can be used as a dashboard close command to cleanly close the dashboard server.py

# --- CLEANUP: Stop existing instances ---

# Kill any existing 'server.py' processes
pkill -f "python.*server.py"

# Kill any existing browser instances
killall -9 brave 2>/dev/null

sleep 1