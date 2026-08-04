#!/bin/bash

# Wait for PulseAudio to be ready
sleep 10

# Set default sink
pacmd set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo

# Disable auto-switching (optional, may not work on all systems)
pacmd unload-module module-switch-on-port-available
