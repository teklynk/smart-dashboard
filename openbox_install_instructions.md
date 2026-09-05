## Installation Openbox on Debian

This will help you get Openbox installed, auto login and the Smart-Dashboard up and running.

**Install Debian and uncheck all desktop environments. Only check SSH Server and System Essentials.**

[![Debian minimal install](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/screenshot6.jpg?raw=true)](![target_url](https://github.com/teklynk/smart-dashboard/blob/main/resources/screenshots/screenshot6.jpg?raw=true))

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

## Install Openbox and lightdm

```bash
sudo apt update
sudo apt install openbox lightdm lightdm-gtk-greeter
```

Create the config directory (if it doesn't exist):
```bash
mkdir -p ~/.config/openbox
```

### Configure Auto-Login with LightDM

To make the system boot directly into Openbox without asking for a password:

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

### Install Bluetooth (optional)

```bash
sudo apt install bluez blueman
sudo systemctl enable --now bluetooth
```

### Install Core Packages

```bash
sudo apt install -y net-tools pavucontrol curl wget python3-full python3-pip \
openjdk-21-jre-headless git openssh-client openssh-server nfs-common \
xdotool xinput input-remapper input-remapper-gtk pkexec unclutter ufw v4l-utils ffmpeg \
flatpak apt-transport-https psmisc wmctrl mpv tilix
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

### Autostart

```bash
nano ~/.config/openbox/autostart
```

Replace your_username with your actual user name.

```bash
#!/bin/bash
bash /home/your_username/scripts/smart-dashboard/run_always.sh &

```

```bash
chmod +x ~/.config/openbox/autostart
```

### Notes And Optional Configurations

Disable password for sudo: This helps to launch apps and tools that require a sudo password.

```bash
sudo nano /etc/sudoers.d/openbox-nopasswd
```

Replace your_username with your actual user name.

```bash
your_username ALL=(ALL) NOPASSWD: ALL
```

Disable all keyboard shortcuts, hotkeys and the desktop menu. (Everything except for Alt-F4)

Backup `~/.config/openbox/rc.xml`

```bash
mv ~/.config/openbox/rc.xml ~/.config/openbox/rc.bkup
```

```bash
nano ~/.config/openbox/rc.xml
```

```bash
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
  <keyboard noremap="yes">
    <chainkeykey>C-g</chainkeykey>
    <keybind key="A-F4">
      <action name="Close"/>
    </keybind>
  </keyboard>
</openbox_config>
```

```bash
openbox --reconfigure
```

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

### tools.json: **tools.json** (example for openbox tools)

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

```json
[
  {
    "id": "blueman",
    "name": "Bluetooth Manager",
    "command": "blueman-manager",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/bluetooth.png",
    "fullscreen": true
  },
  {
    "id": "pavucontrol",
    "name": "PulseAudioControl",
    "command": "pavucontrol",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/volume-up.png",
    "fullscreen": true
  },
  {
    "id": "terminal",
    "name": "Terminal",
    "command": "tilix --full-screen",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/terminal.png",
    "fullscreen": true
  },
  {
    "id": "remapper",
    "name": "Remapper",
    "command": "sudo input-remapper-gtk",
    "requires_confirmation": false,
    "requires_sudo": false,
    "icon": "icons/gamepad.png",
    "fullscreen": false
  },
  {
    "id": "desktop",
    "name": "Close Dashboard",
    "command": "/home/your_username/scripts/smart-dashboard/run_close.sh",
    "requires_confirmation": true,
    "requires_sudo": false,
    "icon": "icons/desktop.png",
    "fullscreen": false
  }
]
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