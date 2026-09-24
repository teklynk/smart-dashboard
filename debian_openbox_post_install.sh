#!/usr/bin/env bash

set -Eeuo pipefail

DASHBOARD_USER="${1:-${SUDO_USER:-}}"
DASHBOARD_REPO="https://github.com/teklynk/smart-dashboard.git"
DASHBOARD_ROOT=""

fail() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

echo "=================================================================="
echo "   Smart-Dashboard Installer Started"
echo "   Experimental - Still in development, use at your own risk."
echo "=================================================================="

if [[ $EUID -ne 0 ]]; then
    fail "Run this script as root. On a minimal install, use: su - -c '$0 <username>'"
fi

[[ -n "$DASHBOARD_USER" ]] || fail "Provide the desktop user: su - -c '$0 <username>'"
id "$DASHBOARD_USER" >/dev/null 2>&1 || fail "User does not exist: $DASHBOARD_USER"

DASHBOARD_HOME="$(getent passwd "$DASHBOARD_USER" | cut -d: -f6)"
[[ -n "$DASHBOARD_HOME" && -d "$DASHBOARD_HOME" ]] || fail "Could not find the home directory for $DASHBOARD_USER"
DASHBOARD_ROOT="$DASHBOARD_HOME/scripts/smart-dashboard"

export DEBIAN_FRONTEND=noninteractive

printf 'Installing Smart Dashboard OpenBox dependencies...\n'

# Enable the repositories required by the documented Debian Trixie setup.
SOURCES_LIST=/etc/apt/sources.list
if [[ -f "$SOURCES_LIST" ]]; then
    mv -f "$SOURCES_LIST" "$SOURCES_LIST.backup"
fi
cat > "$SOURCES_LIST" <<'EOF'
deb http://deb.debian.org/debian trixie main contrib non-free non-free-firmware
deb http://deb.debian.org/debian trixie-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
EOF

# Configure time synchronization in the standard systemd-timesyncd config.
TIMESYNCD_CONFIG=/etc/systemd/timesyncd.conf
if [[ -f "$TIMESYNCD_CONFIG" ]]; then
    mv -f "$TIMESYNCD_CONFIG" "$TIMESYNCD_CONFIG.backup"
fi
cat > "$TIMESYNCD_CONFIG" <<'EOF'
[Time]
NTP=time.cloudflare.com
FallbackNTP=0.debian.pool.ntp.org ntp.ubuntu.com pool.ntp.org
EOF

systemctl enable --now systemd-timesyncd
timedatectl set-ntp true

apt-get update

apt-get install -y sudo
usermod -aG sudo "$DASHBOARD_USER"

apt-get install -y \
    openbox lightdm lightdm-gtk-greeter \
    net-tools pavucontrol curl wget python3-full python3-pip \
    openjdk-21-jre-headless git openssh-client openssh-server nfs-common \
    xdotool xinput input-remapper input-remapper-gtk pkexec unclutter ufw \
    v4l-utils ffmpeg flatpak apt-transport-https psmisc wmctrl mpv tilix \
    picom network-manager network-manager-gnome

# Install Brave Origin, which is used by run.sh for the kiosk window.
curl -fsS https://dl.brave.com/install.sh | FLAVOR=origin bash

# Configure Flathub and install the dashboard's documented desktop apps.
flatpak remote-add --if-not-exists --user flathub https://dl.flathub.org/repo/flathub.flatpakrepo
runuser -u "$DASHBOARD_USER" -- flatpak install --user --noninteractive -y flathub \
    com.github.tchx84.Flatseal \
    org.localsend.localsend_app \
    rocks.shy.VacuumTube \
    tv.kodi.Kodi \
    tv.plex.PlexHTPC \
    org.jellyfin.JellyfinDesktop

# Clone or update the dashboard as the desktop user.
install -d -o "$DASHBOARD_USER" -g "$DASHBOARD_USER" "$DASHBOARD_HOME/scripts"
if [[ -d "$DASHBOARD_ROOT/.git" ]]; then
    runuser -u "$DASHBOARD_USER" -- git -C "$DASHBOARD_ROOT" pull --ff-only
else
    runuser -u "$DASHBOARD_USER" -- git clone "$DASHBOARD_REPO" "$DASHBOARD_ROOT"
fi

runuser -u "$DASHBOARD_USER" -- python3 -m venv "$DASHBOARD_ROOT/venv"
runuser -u "$DASHBOARD_USER" -- "$DASHBOARD_ROOT/venv/bin/pip" install -r "$DASHBOARD_ROOT/requirements.txt"

# Keep user configuration intact when rerunning the installer.
for config in apps tools weather; do
    sample="$DASHBOARD_ROOT/${config}-sample.json"
    target="$DASHBOARD_ROOT/${config}.json"
    if [[ ! -e "$target" ]]; then
        runuser -u "$DASHBOARD_USER" -- cp "$sample" "$target"
    fi
done

# Start LightDM directly into OpenBox for the dashboard user.
LIGHTDM_CONFIG=/etc/lightdm/lightdm.conf
if [[ -f "$LIGHTDM_CONFIG" ]]; then
    mv -f "$LIGHTDM_CONFIG" "$LIGHTDM_CONFIG.backup"
fi
cat > "$LIGHTDM_CONFIG" <<EOF
[Seat:*]
autologin-user=$DASHBOARD_USER
autologin-user-timeout=0
user-session=openbox
EOF

OPENBOX_CONFIG="$DASHBOARD_HOME/.config/openbox"
install -d -o "$DASHBOARD_USER" -g "$DASHBOARD_USER" "$OPENBOX_CONFIG"

if [[ -f "$OPENBOX_CONFIG/rc.xml" ]]; then
    mv -f "$OPENBOX_CONFIG/rc.xml" "$OPENBOX_CONFIG/rc.bkup"
fi
cat > "$OPENBOX_CONFIG/rc.xml" <<'EOF'
<openbox_config xmlns="http://openbox.org/3.4/rc" xmlns:xi="http://www.w3.org/2001/XInclude">
    <desktops>
        <number>1</number>
    </desktops>
    <mouse>
        <screenEdgeWarpTime>0</screenEdgeWarpTime>
    </mouse>
    <focus>
        <followMouse>no</followMouse>
        <focusNew>yes</focusNew>
        <raiseOnFocus>yes</raiseOnFocus>
    </focus>
    <keyboard noremap="yes">
        <chainkeykey>C-g</chainkeykey>
        <keybind key="A-F4">
            <action name="Close"/>
        </keybind>
    </keyboard>
    <window_options>
        <raiseOnFocus>yes</raiseOnFocus>
    </window_options>
</openbox_config>
EOF
chown "$DASHBOARD_USER:$DASHBOARD_USER" "$OPENBOX_CONFIG/rc.xml"

cat > "$OPENBOX_CONFIG/autostart" <<EOF
#!/usr/bin/env bash

xrandr --output HDMI-0 --mode 1920x1080 --primary &

picom -b --backend xrender --vsync &

sleep 10
xdotool mousemove 10 10 click 1 2>/dev/null || true

bash "$DASHBOARD_ROOT/run_always.sh" &
EOF
chown "$DASHBOARD_USER:$DASHBOARD_USER" "$OPENBOX_CONFIG/autostart"
chmod 0755 "$OPENBOX_CONFIG/autostart"

cat > /etc/sudoers.d/openbox-nopasswd <<EOF
$DASHBOARD_USER ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/openbox-nopasswd
visudo -cf /etc/sudoers.d/openbox-nopasswd

systemctl enable lightdm

printf '\nInstallation complete for %s.\n' "$DASHBOARD_USER"
printf 'Log out and back in (or reboot) for the sudo group and LightDM autologin to take effect.\n'
printf 'Before first launch, edit: %s/apps.json, %s/tools.json, and %s/weather.json\n' "$DASHBOARD_ROOT" "$DASHBOARD_ROOT" "$DASHBOARD_ROOT"
