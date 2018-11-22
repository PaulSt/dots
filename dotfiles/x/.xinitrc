#!/bin/bash
#
# ~/.xinitrc

exec xscreensaver -nosplash &

while true; do
    WLAN=$( wicd-cli --wireless -i | sed -n -e 's/^.*Connected to \([A-Za-z0-9]\{0,10\}\).*$/\1/p')
    TEMP=$(echo $(cat /sys/class/thermal/thermal_zone0/temp) | cut -b -2)°C
    BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
    STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
    VOL=$(awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master))
    if [ $(amixer sget Master | grep -c "\[off\]") -eq 1 ]
    then
        VOL="Mute"
    fi
    TIME=$( date +"%d-%b%t%R" )
    xsetroot -name "`echo \| Wlan: $WLAN \| Vol: $VOL \| Bat: $BATT% \| Temp: $TEMP \| $TIME`"
    sleep 15
done &

exec setxkbmap -layout de &

~/.fehbg &

exec dwm
