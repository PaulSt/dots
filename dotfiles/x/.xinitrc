#!/bin/bash
#
# ~/.xinitrc

exec xscreensaver -nosplash &

while true; do
    TEMP=$(echo $(cat /sys/class/thermal/thermal_zone0/temp) | cut -b -2)°C
    BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
    STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
    VOL=$(awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master))
    if [ $(amixer sget Master | grep -c "\[off\]") -eq 1 ]
    then
        VOL="Mute"
    fi
    TIME=$( date +"%d-%b%t%R" )
    xsetroot -name "`echo \| Vol: $VOL \| Bat: $BATT% \| Temp: $TEMP \| $TIME`"
    sleep 30
done &

exec setxkbmap -layout de &

~/.fehbg &

exec dwm
