#!/bin/bash
flatpak run com.protonvpn.www &
sleep 30
xdotool search --name "Proton VPN" windowminimize
