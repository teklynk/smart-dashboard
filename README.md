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

[![In Action](https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot3.jpg?raw=true)](![target_url](https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot3.jpg?raw=true))

## Video Demo
[![Watch the demo](https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot4.jpg?raw=true)](https://odysee.com/@teklynk:c/dashboard-demo-01:8?r=6kei5PPCVaPWL5HURU9aAyq2KXEoE6ki)

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
- **Desktop Environment:** XFCE4
- **Display Manager:** LightDM
- **Browser:** Brave (Origin flavor)
- **Target Hardware:** 2011 Mac Mini (Intel HD 4000) - but should work on most Debian/XFCE setups

## Installation

### 1. Add user to sudoers group

```bash
su -
usermod -aG sudo yourusername
exit
```

### 2. Enable Non-Free Repositories

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo nano /etc/apt/sources.list
```
Add contrib non-free non-free-firmware to each line:

```bash
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
```

### 3. Fix Time Sync (Crucial for apt update)

```bash
sudo apt install systemd-timesyncd
sudo nano /etc/systemd/timesyncd.conf
```
```bash
NTP=time.cloudflare.com
FallbackNTP=0.debian.pool.ntp.org ntp.ubuntu.com pool.ntp.org
```
```bash
sudo systemctl restart systemd-timesyncd
sudo timedatectl set-ntp true
timedatectl status
```
### 4. Install Firmware (2011 Mac Mini Only)

```bash
sudo apt install -y firmware-b43-installer
```

### 5. Install Bluetooth
```bash
sudo apt install bluez blueman
sudo systemctl enable --now bluetooth
```

### 6. Install Core Packages
```bash
sudo apt install -y net-tools network-manager pavucontrol curl wget python3-full python3-pip \
openjdk-21-jre-headless git openssh-client openssh-server gparted nfs-common python3-full \
xdotool xinput input-remapper unclutter ufw powertop v4l-utils lirc evtest onboard ffmpeg \
smartmontools flatpak lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
gnome-disk-utility apt-transport-https psmisc seahorse solaar wmctrl mpv
```
> You can use `wmctrl` to open most desktop apps fullscreen: `flatpak run org.localsend.localsend_app >/dev/null 2>&1 & sleep 1 && wmctrl -r :ACTIVE: -b add,fullscreen,above`

> You can use `mpv` to open a RTSP video stream (security camera) from the command line. mpv has a `--fullscreen` flag option: `mpv --fullscreen rtsp://user:pass@192.168.0.XX:XXXX/unicast`

> You can use `xdotool` to perform window actions: `gparted & sleep 1 && xdotool search --name "/dev/sda - GParted" --limit 1 windowactivate --sync windowstate --add fullscreen above`

### 7. Install Brave Browser
```bash
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh
```

### 8. Set Up Flatpak
```bash
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```
### 9. Install Flatpak Apps
```bash
flatpak install --user flathub -y \
    com.github.tchx84.Flatseal \
    org.localsend.localsend_app \
    rocks.shy.VacuumTube \
    tv.kodi.Kodi \
    tv.plex.PlexHTPC \
    org.jellyfin.JellyfinDesktop
```
### 10. Install FLIRC (IR Remote Support)
```bash
curl apt.flirc.tv/install.sh | sudo bash
```

### 11. Clone and Set Up the Dashboard
```bash
mkdir ~/scripts
cd ~/scripts
git clone https://github.com/teklynk/smart-dashboard.git
cd smart-dashboard
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 12. Run the Dashboard
```bash
./run.sh
```

**Always Run:** You can use the `run_always.sh` script if you want the dashboard to re-open if it is closed. This will wait 3 seconds and launch the dashboard again. Great for when you absolutely do not want anyone to access to desktop.

The dashboard will be available at http://localhost:8080.

> run.sh handles everything: generates backgrounds.json from images in static/backgrounds/, kills any existing instances, starts the Flask server, and launches Brave in kiosk mode pointing at the dashboard.

## Configuration

### apps.json

Defines the apps shown on the dashboard. Each entry includes:

| Field   |      Description      |
|----------|-------------|
| name | Display name (used in the launcher route) |
| icon | Path to the icon image |
| command | Flatpak command for desktop apps, or a URL for web apps |
| force-device-scale-factor | Browser zoom factor for web apps (e.g. 1.25) |

**Desktop app example:**

```bash
{
  "name": "Plex",
  "icon": "icons/plex.png",
  "command": "flatpak run tv.plex.PlexHTPC",
  "force-device-scale-factor": ""
}
```

**Web app example:**

```bash
{
  "name": "Twitch",
  "icon": "icons/twitch.png",
  "command": "https://twitchmultiview.teklynk.com",
  "force-device-scale-factor": "1.25"
}
```
### tools.json

Defines quick-action tools accessible from the dashboard. Fields:

| Field   |      Description      |
|----------|-------------|
| id | Unique identifier used in the /tool route |
| name | Display name |
| command | Shell command to execute |
| requires_confirmation | Whether the frontend should confirm before running |
| requires_sudo | (Currently informational; sudo is not prefixed) |
| icon | Path to the icon image |

### weather.json

```bash
{
  "zipCode": "90210",
  "apiKey": "YOUR_OPENWEATHER_API_KEY",
  "units": "imperial"
}
```
Replace the API key with your own from [OpenWeather](https://openweathermap.org/api).

## Backgrounds

Place wallpaper images (.jpg, .png, .gif, .webp) in static/backgrounds/. The run.sh script auto-generates backgrounds.json at startup.

# Post-Install Setup

### Configure Auto-Login (LightDM)

Edit the LightDM config:

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Under [Seat:*], set:

```bash
[Seat:*]
autologin-user=yourusername
autologin-user-timeout=0
```

### Auto-Start the Dashboard
Add run.sh to XFCE's Session and Startup:

1. Open Settings → Session and Startup
2. Go to the Application Autostart tab
3. Add a new entry pointing to the full path of run.sh

> `run.sh` includes `unclutter` and sets `xset -dpms s off` to prevent the display from going to sleep.

### Install the Desktop Entry

```bash
mkdir -p ~/.local/share/applications
cp dashboard.desktop ~/.local/share/applications/
```

### Disable Panel Autostart in Session Settings
The most reliable method is to tell the session manager explicitly not to launch the panel. 

1. Open **Session and Startup** (search for it in your application menu). 
2. Go to the **Session** tab (sometimes labeled Current Session). 
3. Locate **xfce4-panel** in the list of running applications. 
4. Change the **Restart Style** column for xfce4-panel to Never. 
5. Crucial Step: **Save Session** as the default and reboot.

To restore the panel, simply run `xfce4-panel` and go back to **Session and Startup > Current Session**. Set **xfce4-panel** to **Immediately** and **Save Session**.

### Disable Keyboard Application Shortcuts

Got to: **Settings Manager > Keyboard**. Select the **Application Shortcuts** and remove all keyboard shortcuts that you are not using. 

### True Kiosk Mode Setup (optional)
You can completely disable the desktop. If you do this you may want to use the `run_always.sh` script so that the dashboard re-opens if it is closed.
Create a 'dummy' xfdesktop file.

```bash
sudo cp /usr/bin/xfdesktop /usr/bin/xfdesktop.real
```
```bash
sudo rm /usr/bin/xfdesktop
```
```bash
sudo nano /usr/bin/xfdesktop
```
Paste the following content:
```bash
#!/bin/bash
# Fake xfdesktop script for Kiosk Mode
# This script prevents the desktop manager from running,
# effectively disabling the right-click menu, desktop icons, panels, applets...

# Do nothing. Exit immediately.
exit 0
```
```bash
sudo chmod +x /usr/bin/xfdesktop
```
This does mean that you will now only be able to add apps, files via SSH. Which could be good depending on your use case.

### Configure Input Remapping

Use input-remapper-gtk to map remote or keyboard buttons. Map a key to Alt+F4 so web apps can be closed without a keyboard.

> Important: Save your preset to your home directory and set it to auto-load on login.

### Prevent Sleep/Suspend

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### Configure Firewall

```bash
sudo ufw allow from 192.168.0.0/24 to any proto tcp port 22
sudo ufw enable
```

## Troubleshooting & Tips

### Screen Locking on Wake

**Method 1 - Power Manager GUI:**
- Open **Settings → Power Manager → Security tab**
- Uncheck *"Lock screen when system is going to sleep"*
- Uncheck *"Lock screen when system is idle"*

**Method 2 - Disable Screen Locker Autostart:**
- Open **Settings → Session and Startup → Application Autostart**
- Uncheck **Screen Locker** (or `light-locker` / `xfce4-screensaver`)
- Reboot

### Configure PulseAudio:
- Open `pavucontrol` (PulseAudio Volume Control)
- Go to the **Configuration** tab
- Set "Built-in Audio" profile to **Digital Stereo (HDMI) Output**
- Go to the **Output Devices** tab and set HDMI as the fallback device

### Set Default Audio Device

Find your audio device name
```bash
pactl list-sinks | grep -A1 index
```
Set your default audio device (replace with your device name)
```bash
pactl set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo
```
Disable auto switching to other audio devices
```bash
pactl unload-module module-switch-on-port-available
```

Make the setting persist reboot:
```bash
nano ~/scripts/audio-setup.sh
```

```bash
#!/bin/bash
sleep 10
pactl set-default-sink alsa_output.pci-0000_00_1b.0.hdmi-stereo
# Disable auto-switching via pactl
pactl unload-module module-switch-on-port-available
```

Create a auto start application entry under **Session and Startup Applications**

### Password Prompt on Auto-Login

If you are prompted to enter your password even though auto-login is enabled:

1. Open `seahorse` in the terminal
2. Delete current `Login`
3. Create a new keyring named `Login` (case-sensitive) with a **blank** password
4. Right-click it → **Set as default**
5. Reboot - the blank-password Login keyring will auto-unlock during auto-login

### Navigation

**Arrow keys** will let you move through the main apps/icons. 

**Tab and Shift+Tab** will let you access the Tool Bar apps/icons. 

**Alt+F4** will close most apps and web apps. 
