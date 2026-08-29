# What Is Smart Dashboard?

[![In Action](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/dashboard_IMG_0951.jpg?raw=true)](![target_url](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/dashboard_IMG_0951.jpg?raw=true))

### Turn any computer into a smart-TV-style home screen

Click an icon → launch an app. Whether it's a desktop app (Plex, Kodi), a system command (shutdown, settings), or a website (Twitch, a business dashboard) — everything lives on the same fullscreen grid and launches with one click. Websites don't open in browser tabs — they become immersive, sandboxed web apps that fill the screen like native software.

Smart Dashboard is designed to *always be running*. It launches on boot, sits as your home screen, and resists accidental closure. Launch an app, it opens on top. Close it, and you're back at your grid. No desktop clutter, no hidden shortcuts, no escaping.

## One Dashboard, Many Roles

This isn't just a media center launcher. It's a platform that adapts to whatever you need:

| Role | What it becomes |
|---|---|
| **Media Center PC** | Couch-first computing: Plex, Jellyfin, YouTube, streaming — all one click away |
| **Kid's Computer** | Restricted, curated access. Only approved apps exist; nowhere else to wander |
| **Business Kiosk** | Wall-mounted display showing catalogs, appointment booking, order forms, store maps |
| **Repurposed Hardware** | Old laptop or mini-PC reborn as a dedicated appliance |
| **Guest Terminal** | Welcome screen in an Airbnb, office, or waiting room |
| **IoT Control Panel** | Local dashboards, camera feeds, automation tools on a single screen |

> *If you can make it run, show it, or open — it can live on the grid.*

## Quick Start

### Installation Options

Choose your setup based on needs:

- **[OpenBox](openbox_install_instructions.md)** — Minimal, lightweight. Just a window manager and compositor. Ideal for dedicated kiosks.
- **[XFCE](xfce_install_instructions.md)** — Full desktop capabilities. Great if you need to switch users or access a traditional desktop environment.

Both options are tested on **Debian 13 (Trixie)**.

### System Requirements

- **OS:** Debian 13 (Trixie)
- **Desktop Environment:** XFCE4 or OpenBox
- **Display Manager:** LightDM
- **Browser:** Brave (Origin flavor)

## Configuration

Everything is driven by plain JSON files and CSS. No database, no build step.

| File | Purpose |
|---|---|
| `apps.json` | Define which apps appear, their icons, launch commands, and per-app scaling |
| `tools.json` | Define system actions in the toolbar (upper right): shutdown, settings, custom scripts |
| `weather.json` | Set your location and weather API key |
| `static/backgrounds/` | Drop in wallpaper images — auto-detected and rotated every 5 minutes with dissolve transition |
| CSS | Customize colors, layout, sizing, and overall appearance |

## Navigation

| Input | Action |
|---|---|
| Arrow keys | Navigate through main app icons |
| Tab / Shift+Tab | Access toolbar icons |
| Alt+F4 | Close active web/desktop apps |

**Remote control supported:** Works with the [MX3 Pro Mini Keyboard Backlight Fly Remote Mouse](https://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=MX3+Pro+Mini+Keyboard+Backlight+Fly+Remote+Mouse). Map a key to Alt+F4 to close apps wirelessly. [MX3 Pro Key Mappings](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/mx3-pro-remote-key-map.jpg)

## Under the Hood

### How It Works

The UI runs in a web browser. A Python/Flask backend handles launching apps and routing commands.

| Route | Purpose |
|---|---|
| `/` | Renders the dashboard with apps, tools, weather, and backgrounds |
| `/launch?app=AppName` | Launches a desktop app (Flatpak) or web app (Brave kiosk) |
| `/tool?tool=ToolID` | Executes a system tool/action |

**Web apps** launch in isolated Brave instances:

```bash
brave-origin --app="<url>" --kiosk --class=WebApp-<Name> --name=WebApp-<Name> --user-data-dir=<unique-dir> --force-device-scale-factor=<factor>
```

Each gets its own user data directory and window class, allowing the dashboard to cleanly close one app before opening another.

**Desktop apps** launch via their command (typically flatpak run ...).

## Recommended Add-ons

These optional tools extend Smart Dashboard further:

- **UFW** — Firewall rules
- **Static IP** — /etc/network/interfaces
- **LIRC** — IR remote sensor support
- **uxplay** — Mirror iPhone/iPad to Linux
- **RetroDECK** — Retro gaming platform manager
- **Docker** — Run local web services/apps
- **Video Conferencing** — Webcam integration with talk.brave.com
- **caldera-music** — Multi-room music (Plexamp alternative)

## Demos

## Video Demo (Debian & Openbox)
[![Watch the demo](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/screenshot5.jpg?raw=true)](https://odysee.com/@teklynk:c/Smart-Dashboard-Debian-Openbox:1?r=6kei5PPCVaPWL5HURU9aAyq2KXEoE6ki)

## Video Demo (Debian & XFCE)
[![Watch the demo](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/screenshot4.jpg?raw=true)](https://odysee.com/@teklynk:c/dashboard-demo-01:8?r=6kei5PPCVaPWL5HURU9aAyq2KXEoE6ki)