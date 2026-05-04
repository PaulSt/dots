#!/bin/bash

# Source Arch xinit scripts; important for dbus/systemd user environment.
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

export XDG_CURRENT_DESKTOP=dwm

# Get all possible displays
allposs=$(xrandr -q | grep "connected")
# Get all connected screens.
screens=$(echo "$allposs" | awk '/ connected/ {print $1}')

#exec xscreensaver -nosplash &

while true; do
    SEP="    "

    IFACE="$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"

    case "$IFACE" in
        "") NET="󰖪 offline" ;;
        en*|eth*) NET="󰈀 $(ip -4 -o addr show "$IFACE" | awk '{split($4,a,"/"); print a[1]; exit}')" ;;
        *) NET=" $(iwctl station "$IFACE" show 2>/dev/null | awk -F'Connected network' '/Connected network/ {gsub(/^ +/,"",$2); print $2}')" ;;
    esac

    V="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)"
    echo "$V" | grep -q MUTED && VOL=" mute" || VOL=" $(echo "$V" | awk '{printf "%d%%", $2*100}')"

    WEATHER="$(curl -fsS --max-time 2 'wttr.in/Vienna?format=%c%t' 2>/dev/null)"

    TEMP=" $(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))°C"
    TIME=" $(date '+%d-%b %R')"

    xsetroot -name "$NET$SEP$VOL$SEP$WEATHER$SEP$TEMP$SEP$TIME"
    sleep 60
done &

setxkbmap -layout us &

# for zoom screen share
#xcompmgr -c -l0 -t0 -r0 -o.00 &

xset -dpms
xset s off
xset s noblank

feh --no-fehbg --bg-fill "$HOME/.local/share/wallpapers/bg.jpg" &

if [[ $(xrandr --listactivemonitors | grep ' DP-1') != "" ]]; then
    xrandr --output eDP-1 --off --output DP-1 --auto
    xrdb -merge .Xresources4k
fi

source ~/.bashrc

# for gnome keyring update pam  https://wiki.archlinux.org/title/GNOME/Keyring#Automatically_change_keyring_password_with_user_password
#eval $(gnome-keyring-daemon --start)
#export SSH_AUTH_SOCK
#source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK

udiskie --automount &
mkdir -p ~/media
ln -sfn "/run/media/$USER" "$HOME/media"

exec dwm
