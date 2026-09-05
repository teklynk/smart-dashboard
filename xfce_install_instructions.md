## Installation XFCE on Debian

This will help you get XFCE configured, auto login and the Smart-Dashboard up and running.

**Install Debian and check XFCE. Uncheck all other desktop environments. Check SSH Server and System Essentials.**

### SSH into Debian

Once the install finishes and you have rebooted, you can now log in from the prompt and find your IP address.

```bash
ip address
```

From this point on, you can SSH into Debian from another PC using the IP address of your Debian install. This will make copy and paste commands easier. `ssh your_username@ipaddress` Once you are in you can proceed with the rest of the instructions.

### Add user to sudoers group

```bash
su -

apt install sudo

usermod -aG sudo your_username

exit
```

Log off completely and ssh back into Debian. You should now be able to run sudo commands.

### Enable Non-Free Repositories

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup
sudo nano /etc/apt/sources.list
```

Comment out all lines in `/etc/apt/sources.list` and add the lines to the bottom OR simply add `contrib non-free non-free-firmware` to each line:

```bash
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
```

### Fix Time Sync (Crucial for apt update)

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

### Install Firmware (2011 Mac Mini Only)

```bash
sudo apt install -y firmware-b43-installer 

sudo apt install mbpfan

sudo systemctl enable mbpfan.service
sudo systemctl daemon-reload
sudo systemctl start mbpfan.service
sudo systemctl status mbpfan.service
```
> `mbpfan` is a fan control daemon that works with older macbooks, imac and mac mini

### Install Bluetooth
```bash
sudo apt install bluez blueman
sudo systemctl enable --now bluetooth
```

### Install Core Packages
```bash
sudo apt install -y net-tools network-manager pavucontrol curl wget python3-full python3-pip \
openjdk-21-jre-headless git openssh-client openssh-server nfs-common \
xdotool xinput input-remapper input-remapper-gtk pkexec unclutter ufw v4l-utils ffmpeg \
flatpak lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings \
apt-transport-https psmisc seahorse wmctrl mpv tilix
```
> You can use `wmctrl` to open most desktop apps fullscreen: `flatpak run org.localsend.localsend_app >/dev/null 2>&1 & sleep 1 && wmctrl -r :ACTIVE: -b add,fullscreen,above`

> You can use `mpv` to open a RTSP video stream (security camera) from the command line. mpv has a `--fullscreen` flag option: `mpv --fullscreen rtsp://user:pass@192.168.0.XX:XXXX/unicast`

> You can use `xdotool` to perform window actions: `gparted & sleep 1 && xdotool search --name "/dev/sda - GParted" --limit 1 windowactivate --sync windowstate --add fullscreen above`

### Install Brave Browser

```bash
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin sh
```

### Set Up Flatpak

```bash
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

### Install Flatpak Apps

```bash
flatpak install --user flathub -y \
    com.github.tchx84.Flatseal \
    org.localsend.localsend_app \
    rocks.shy.VacuumTube \
    tv.kodi.Kodi \
    tv.plex.PlexHTPC \
    org.jellyfin.JellyfinDesktop
```

### Clone and Set Up the Dashboard

```bash
mkdir ~/scripts
cd ~/scripts
git clone https://github.com/teklynk/smart-dashboard.git
cd smart-dashboard
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### JSON config files

Rename `apps-sample.json`, `tools-sample.json` and `weather-sample.json` to `apps.json`, `tools.json`, `weather.json`

### Run the Dashboard

```bash
./run.sh
```

**Always Run:** You can use the `run_always.sh` script if you want the dashboard to re-open if it is closed. This will wait 3 seconds and launch the dashboard again. Great for when you absolutely do not want anyone to access to desktop.

The dashboard will be available at http://localhost:8080.

> `run.sh` handles everything: generates backgrounds.json from images in static/backgrounds/, kills any existing instances, starts the Flask server, and launches Brave in kiosk mode pointing at the dashboard.

## Configuration

### apps.json

Defines the apps shown on the dashboard. Each entry includes:

| Field   |      Description      |
|----------|-------------|
| name | Display name (used in the launcher route) |
| icon | Path to the icon image |
| command | Flatpak command for desktop apps, or a URL for web apps |
| force-device-scale-factor | Browser zoom factor for web apps (e.g. 1.25) |
| incognito | opens the web app in incognito mode |
| fullscreen | forces the app/tool to open fullscreen (requires `wmctrl`). Does not apply to web apps |

**Desktop app example:**

```bash
{
  "name": "Plex",
  "icon": "icons/plex.png",
  "command": "flatpak run tv.plex.PlexHTPC",
  "force-device-scale-factor": "",
  "incognito": false,
  "fullscreen": false
}
```

**Web app example:**

```bash
{
  "name": "Twitch",
  "icon": "icons/twitch.png",
  "command": "https://twitchmultiview.teklynk.com",
  "force-device-scale-factor": "1.25",
  "fullscreen": false
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
| fullscreen | forces the app/tool to open fullscreen (requires `wmctrl`). Does not apply to web apps |

```bash
  {
    "id": "shutdown",
    "name": "Shutdown",
    "command": "xfce4-session-logout",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/power-off.png",
    "fullscreen": false
  },
  {
    "id": "settings",
    "name": "Settings Manager",
    "command": "xfce4-settings-manager",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/gear.png",
    "fullscreen": false
  }
```

### weather.json

```bash
{
  "zipCode": "90210",
  "apiKey": "YOUR_OPENWEATHER_API_KEY",
  "units": "imperial"
}
```
> Replace the API key with your own from [OpenWeather](https://openweathermap.org/api).

## Backgrounds

Place wallpaper images (.jpg, .png, .gif, .webp) in static/backgrounds/. The run.sh script auto-generates backgrounds.json at startup.

# Post-Install Setup

### Configure Auto-Login with LightDM

To make the system boot directly into XFCE without asking for a password:

```bash
sudo nano /etc/lightdm/lightdm.conf
```
Find `[Seat:*]`, and add these lines. Replace your_username with your actual user name.

```bash
[Seat:*]
autologin-user=your_username
autologin-user-timeout=0
```

```bash
sudo systemctl enable lightdm
sudo systemctl start lightdm
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

### Password Prompt on Auto-Login

If you are prompted to enter your password even though auto-login is enabled:

1. Open `seahorse` in the terminal
2. Delete current `Login`
3. Create a new keyring named `Login` (case-sensitive) with a **blank** password
4. Right-click it → **Set as default**
5. Reboot - the blank-password Login keyring will auto-unlock during auto-login

### Notes And Optional Configurations

Disable password for sudo: This helps to launch apps and tools that require a sudo password.

```bash
sudo nano /etc/sudoers.d/xfce-nopasswd
```

```bash
your_username ALL=(ALL) NOPASSWD: ALL