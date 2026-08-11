#!/bin/bash

#UXPlay iOS Screen Mirroring

#sudo apt install uxplay

# Ensure these firewall ports are open on the Linux machine
#sudo ufw allow from 192.168.0.0/24 to any proto tcp port 7001 comment "Internal - UXPlay"
#sudo ufw allow from 192.168.0.0/24 to any proto tcp port 7000 comment "Internal - UXPlay"
#sudo ufw allow from 192.168.0.0/24 to any proto tcp port 7100 comment "Internal - UXPlay"
#sudo ufw allow from 192.168.0.0/24 to any proto udp port 7011 comment "Internal - UXPlay"
#sudo ufw allow from 192.168.0.0/24 to any proto udp port 6001 comment "Internal - UXPlay"
#sudo ufw allow from 192.168.0.0/24 to any proto udp port 6000 comment "Internal - UXPlay"
#sudo ufw reload

# Wait for the network and display server to be fully ready
sleep 5

# Export DISPLAY if not already set (usually handled by XFCE session)
export DISPLAY=:0

# Optional: Ensure DBus session is available
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

# Launch UxPlay
# -fs: Fullscreen
# -p: Use fixed legacy ports (7000/6000 series)
uxplay -fs -p > /dev/null 2>&1