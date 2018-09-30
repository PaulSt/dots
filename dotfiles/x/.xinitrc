#!/bin/bash
#
# ~/.xinitrc

exec xscreensaver -nosplash &

while true; do
  BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
  STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
  VOL=$(awk -F"[][]" '/dB/ { print $2 }' <(amixer sget Master))
  if [ $(amixer sget Master | grep -c "\[off\]") -eq 1 ]
  then
      VOL="Mute"
  fi
	TIME=$( date +"%d-%b%t%R" )
	xsetroot -name "`echo \| Vol: $VOL \| Bat: $BATT% \| $TIME`"
	sleep 30
done &

exec setxkbmap -layout de &

~/.fehbg &

exec dwm
