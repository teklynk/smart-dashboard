## Installation Openbox on Debian

This will help you get Openbox installed, auto login and the Smart-Dashboard up and running.

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
sudo apt install -y net-tools network-manager pavucontrol curl wget python3-full python3-pip \
openjdk-21-jre-headless git openssh-client openssh-server nfs-common \
xdotool xinput input-remapper input-remapper-gtk unclutter ufw v4l-utils ffmpeg \
smartmontools flatpak gnome-disk-utility apt-transport-https psmisc wmctrl mpv
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