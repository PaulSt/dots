#!/bin/bash
#
# ~/.xinitrc

exec xscreensaver -nosplash &

while true; do
  BATT=$( acpi -b | sed 's/.*[Full|charging|unknown], \([0-9]*\)%.*/\1/gi' )
  STATUS=$( acpi -b | sed 's/.*: \([a-zA-Z]*\),.*/\1/gi' )
	TIME=$( date +"%d-%b%t%R" )
	xsetroot -name "`echo $BATT%  $TIME`"
	sleep 60
done &

~/.fehbg &

exec dwm 
