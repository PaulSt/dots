#!/bin/bash
#
# ~/.xinitrc

# Get all possible displays
allposs=$(xrandr -q | grep "connected")
# Get all connected screens.
screens=$(echo "$allposs" | awk '/ connected/ {print $1}')

#exec xscreensaver -nosplash &

while true; do
    WLAN=" $(iwctl station wlan0 show | awk '/Connected network/ {print $3}')"
    if [ -z "$WLAN" ]; then
        WLAN="Not Connected"
    fi
    # run cat /sys/class/thermal/thermal_zone*/type to check the thermometers available
    TEMP=" $(echo $(cat /sys/class/thermal/thermal_zone0/temp) | cut -b -2)°C"
    if acpi -b | grep -q "Discharging"; then
        BATT="🔋"
    else
        BATT="🔌"
    fi
    BATT+=" $( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )%"
    #STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
    #DB=$( dropbox-cli status ) use this icon  $DB \
    VOL=" $(awk -F"[][]" '/%/ { print $2 }' <(amixer sget Master))"
    if [ $(amixer sget Master | grep -c "\[off\]") -ge 1 ]; then
        VOL=" Mute"
    fi
    TIME=" $( date +"%d-%b%t%R" )"

    xsetroot -name "`echo $WLAN \ $VOL \ $BATT \ $TEMP \ $TIME`"
    sleep 15
done &

setxkbmap -layout us &

# for zoom screen share
xcompmgr -c -l0 -t0 -r0 -o.00 &

if [[ $(xrandr --listactivemonitors | grep ' DP-1') != "" ]]; then
    xrandr --output eDP-1 --off --output DP-1 --auto 
    xrdb -merge .Xresources4k
fi

~/.fehbg &
source ~/.bashrc

# for gnome keyring update pam  https://wiki.archlinux.org/title/GNOME/Keyring#Automatically_change_keyring_password_with_user_password
#eval $(gnome-keyring-daemon --start)
#export SSH_AUTH_SOCK
#source /etc/X11/xinit/xinitrc.d/50-systemd-user.sh

#eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
#export SSH_AUTH_SOCK

exec dwm
