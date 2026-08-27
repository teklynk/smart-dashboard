## Installation Openbox on Debian

This will help you get Openbox installed, auto login and the Smart-Dashboard up and running.

**Install Debian and uncheck all desktop environments. Only check SSH Server and System Essentials.**

### Add user to sudoers group

```bash
su -
usermod -aG sudo yourusername
exit
```

### Enable Non-Free Repositories

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

### Install Openbox
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

```bash
[Seat:*]
autologin-user=your_username
autologin-user-timeout=0
```

```bash
sudo systemctl enable lightdm
sudo systemctl start lightdm
```

### Install Bluetooth
```bash
sudo apt install bluez blueman
sudo systemctl enable --now bluetooth
```

### Install Core Packages
```bash
sudo apt install -y net-tools pavucontrol curl wget python3-full python3-pip \
openjdk-21-jre-headless git openssh-client openssh-server nfs-common \
xdotool xinput input-remapper input-remapper-gtk pkexec unclutter ufw v4l-utils ffmpeg \
flatpak apt-transport-https psmisc wmctrl mpv
```

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

### Autostart
```bash
nano ~/.config/openbox/autostart
```

```bash
#!/bin/bash
bash /home/user/scripts/smart-dashboard/run_always.sh &

```

```bash
chmod +x ~/.config/openbox/autostart
```

### Notes And Optional Configurations

Disable password for sudo: This helps to launch apps and tools that require a sudo password.

```bash
sudo nano /etc/sudoers.d/openbox-nopasswd
```

```bash
yourusername ALL=(ALL) NOPASSWD: ALL
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

Openbox: **tools.json** (example)

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
    "command": "killall -9 brave",
    "requires_confirmation": true,
    "requires_sudo": false,
    "icon": "icons/desktop.png",
    "fullscreen": false
  }
```