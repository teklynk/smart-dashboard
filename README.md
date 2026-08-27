# What Is Smart Dashboard?
Smart Dashboard is a web interface that runs inside a browser in fullscreen kiosk mode, presenting a clean, app-grid layout similar to a smart TV home screen. Behind the scenes, a Python/Flask backend handles launching desktop apps, executing system commands, and opening web URLs - all triggered by clicking icons on the dashboard.

The key idea: everything is treated like an app. Whether it's a Flatpak desktop application (Plex, Kodi, Jellyfin), a system command (shutdown, settings), or a web URL (Twitch, a local dashboard) - they all appear as icons on the grid and launch with a single click. Web URLs don't just open in a browser tab - they launch as sandboxed web apps in their own kiosk-style Brave instance, each with its own .config directory, window class, and scaling factor. This gives web apps the same fullscreen, immersive feel as native apps.

The dashboard itself is designed to always be running. It launches on boot/login via autostart and sits as your home screen. Attempting to close it (via Alt+F4 or otherwise) triggers a confirmation prompt, so accidental exits won't happen. When you launch an app, it appears on top of the dashboard - when you close that app, you're right back at the home screen.

Everything is configurable through plain JSON files and CSS:

- **apps.json** - define which apps appear, their icons, launch commands, and per-app scaling
- **tools.json** - define system actions in the toolbar (upper right), like shutdown, settings, or custom scripts
- **weather.json** - set your location and weather API key
- **CSS** - customize colors, layout, sizing, and appearance to your taste
- **static/backgrounds/** - drop in your own wallpaper images; they're auto-detected and rotate every 5 minutes with a dissolve transition

## Use Cases

Smart Dashboard is flexible enough for many scenarios:

- **Media center PC** - a TV-connected mini PC with Plex, Jellyfin, Kodi, and YouTube one click away
- **Workplace dashboard** - a wall-mounted display showing internal tools, dashboards, or informational kiosks
- **Infotainment kiosk** - a public-facing screen with curated apps and no way for users to escape to the desktop
- **Repurposed hardware** - give an old laptop or mini PC a second life as a dedicated appliance

If you can think of a use case, you just set the apps and tools you want, point it at the URLs or Flatpak apps you need, and let it run.

[![In Action](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/dashboard_IMG_0951.jpg?raw=true)](![target_url](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/dashboard_IMG_0951.jpg?raw=true))

## Video Demo
[![Watch the demo](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/screenshot4.jpg?raw=true)](https://odysee.com/@teklynk:c/dashboard-demo-01:8?r=6kei5PPCVaPWL5HURU9aAyq2KXEoE6ki)

## Features

- **App Launcher** - Click icons to launch Flatpak desktop apps (Plex, Jellyfin, Kodi, YouTube) or web apps (Twitch, custom URLs) that open as standalone kiosk windows via Brave
- **Web App Management** - Web apps launch in their own Brave instance with a unique window class, allowing the dashboard to cleanly close one web app before opening another
- **Tools Panel** - Quick access to system actions: Shutdown, Settings Manager, Input Remapper, and Close Dashboard
- **Wallpaper Rotation** - Automatically scans static/backgrounds/ for images and generates backgrounds.json at startup
- **Weather Widget** - Displays local weather using the OpenWeather API
- **Kiosk Mode** - The dashboard itself runs fullscreen in Brave kiosk mode, giving it the look and feel of a native smart TV interface
- **Remote Friendly** - Designed to work with FLIRC and input-remapper for IR remote or keyboard control; map a key to Alt+F4 to close web apps

## How It Works
The UI runs in a web browser and uses Python and Flask to route

The Flask backend (server.py) serves the dashboard frontend and handles two main routes:
| Route   |      Purpose      |
|----------|-------------|
| / | Renders the dashboard page with apps, tools, weather, and backgrounds |
| /launch?app=AppName | Launches a desktop app (Flatpak) or web app (Brave kiosk) |
| /tool?tool=ToolID | Executes a system tool/action |

**Web apps** (URLs starting with http:// or https://) are launched using:
```bash
/usr/bin/brave-origin-stable --app="<url>" --kiosk --class=WebApp-<Name> --name=WebApp-<Name> --user-data-dir=<unique-dir> --force-device-scale-factor=<factor>
```
Each web app gets its own user data directory and window class, allowing the server to detect and cleanly terminate the previous web app before launching a new one.

**Desktop apps** are launched via their command (typically flatpak run ...).

## System Requirements
This project was developed and tested on:

- **OS:** Debian 13 (Trixie)
- **Desktop Environment:** XFCE4 or OpenBox
- **Display Manager:** LightDM
- **Browser:** Brave (Origin flavor)
- **Target Hardware:** 2011 Mac Mini (Intel HD 4000) - but should work on most Debian setups

## Installation

You can use **OpenBox** or **XFCE** on top of the base install of Debian. 

( [XFCE instructions](https://github.com/teklynk/smart-dashboard/blob/main/xfce_install_instructions.md) )

( [OpenBox instructions](https://github.com/teklynk/smart-dashboard/blob/main/openbox_install_instructions.md) )


### Navigation

**Arrow keys** will let you move through the main apps/icons. 

**Tab and Shift+Tab** will let you access the Tool Bar apps/icons. 

**Alt+F4** will close most apps and web apps. 

**MX3 Pro Mini Keyboard Backlight Fly Remote Mouse**

These are the key mappings that I set using input-remapper

[![MX3 Pro Remote](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/mx3-pro-remote-key-map.jpg?raw=true)](![target_url](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/mx3-pro-remote-key-map.jpg?raw=true))