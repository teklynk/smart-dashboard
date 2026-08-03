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

<a target="_blank" rel="noopener noreferrer" href="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot2.jpg?raw=true"><img src="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot2.jpg?raw=true" style="max-width: 100%;"></a>

<a target="_blank" rel="noopener noreferrer" href="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot3.jpg?raw=true"><img src="https://github.com/teklynk/smart-dashboard/blob/main/screenshots/screenshot3.jpg?raw=true" style="max-width: 100%;"></a>

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
usermod -aG sudo YourUser
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
gnome-disk-utility apt-transport-https psmisc seahorse
```

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

## Post-Install Setup

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

Also consider auto-starting unclutter (hides the mouse cursor when idle).

### Install the Desktop Entry

```bash
mkdir -p ~/.local/share/applications
cp dashboard.desktop ~/.local/share/applications/
```

### Configure Input Remapping

Use input-remapper-gtk to map remote or keyboard buttons. Map a key to Alt+F4 so web apps can be closed without a keyboard.

> Important: Save your preset to your home directory and set it to auto-load on login.

### Configure XFCE Panel

For a clean TV experience:

- Remove all panels except one (XFCE requires at least one panel to exist)
- Remove all panel applets
- Set panel transparency
- Set the panel to auto-hide

### Prevent Sleep/Suspend

```bash
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

### Configure Firewall

```bash
sudo ufw allow from 192.168.0.0/24 to any proto tcp port 22
sudo ufw enable
```

## Troubleshooting

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

### Password Prompt on Auto-Login

If you are prompted to enter your password even though auto-login is enabled:

1. Open `seahorse` in the terminal
2. Delete current `Login`
3. Create a new keyring named `Login` (case-sensitive) with a **blank** password
4. Right-click it → **Set as default**
5. Reboot - the blank-password Login keyring will auto-unlock during auto-login