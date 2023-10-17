#!/bin/bash
#
# ~/.xinitrc

# Get all possible displays
allposs=$(xrandr -q | grep "connected")
# Get all connected screens.
screens=$(echo "$allposs" | awk '/ connected/ {print $1}')

if [[ $screens == *"HDMI1"* ]]; then
    xrandr --output eDP1 --off
    xrandr --output HDMI1 --auto --scale 1.0x1.0
fi

if [[ $screens == *"DP1-1"* ]] & [[ $screens == *"DP1-3"* ]]; then
    xrandr --output eDP1 --off
    xrandr --output DP1-1 --auto --scale 1.0x1.0
    #xrandr --output DP1-2 --off
    xrandr --output DP1-3 --right-of DP1-1 --auto --scale 1.0x1.0
    #xrandr --output eDP1 --right-of DP1-1 --auto --scale 1.0x1.0
    xsetwacom set "Wacom One Pen Display 13 Pen stylus" MapToOutput DP1-3
    #xsetwacom list devices
    #xrandr --output DP1-3 --off
    #xrandr --output DP1-2 --right-of DP1-1 --auto --scale 1.0x1.0 --rotate left
    #xrandr --output DP1-2 --off
    #xrandr --output DP1-1 --auto --scale 1.0x1.0
fi

exec xscreensaver -nosplash &

while true; do
    WLAN=$( iw dev wlo1 link | sed -n -e 's/^.*SSID: //p')
    if [ -z "$WLAN" ]; then
        WLAN="Not Connected"
    fi

    # run cat /sys/class/thermal/thermal_zone*/type to check the thermometers available
    TEMP=$(echo $(cat /sys/class/thermal/thermal_zone8/temp) | cut -b -2)°C
    BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
    STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
    #DB=$( dropbox-cli status ) use this icon  $DB \
    VOL=$(awk -F"[][]" '/%/ { print $2 }' <(amixer sget Master))
    if [ $(amixer sget Master | grep -c "\[off\]") -ge 1 ]; then
        VOL="Mute"
    fi
    TIME=$( date +"%d-%b%t%R" )
    if [ "$BATT" -gt "90" ]; then
        BATTICON="\f017"
    fi

    xsetroot -name "`echo   $WLAN \  $VOL \  $BATT% \  $TEMP \  $TIME`"
    sleep 15
done &

exec setxkbmap -layout de &

~/.fehbg &
source ~/.bashrc

# for gnome keyring update pam  https://wiki.archlinux.org/title/GNOME/Keyring#Automatically_change_keyring_password_with_user_password
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK

exec dwm
