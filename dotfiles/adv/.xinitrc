#!/bin/bash
#
# ~/.xinitrc

exec xscreensaver -nosplash &

while true; do
    WLAN=$( iw dev wlan0 link | sed -n -e 's/^.*SSID: //p')
    if [ -z "$WLAN" ]; then
        WLAN="Not Connected"
    fi
    TEMP=$(echo $(cat /sys/class/thermal/thermal_zone0/temp) | cut -b -2)°C
    BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
    STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
    DB=$( dropbox-cli status )
    VOL=$(awk -F"[][]" '/%/ { print $2 }' <(amixer sget Master))
    if [ $(amixer sget Master | grep -c "\[off\]") -ge 1 ]; then
        VOL="Mute"
    fi
    TIME=$( date +"%d-%b%t%R" )
    if [ "$BATT" -gt "90" ]; then
        BATTICON="\f017"
    fi

    xsetroot -name "`echo   $DB \  $WLAN \  $VOL \  $BATT% \  $TEMP \  $TIME`"
    sleep 15
done &

exec setxkbmap -layout de &

~/.fehbg &

exec  redshift -l 48:16 &

exec dwm
