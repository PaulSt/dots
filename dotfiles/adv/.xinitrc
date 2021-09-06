#!/bin/bash
#
# ~/.xinitrc

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

# for gnome keyring update pam  https://wiki.archlinux.org/title/GNOME/Keyring#Automatically_change_keyring_password_with_user_password
eval $(gnome-keyring-daemon --start)
export SSH_AUTH_SOCK
source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK

exec dwm
