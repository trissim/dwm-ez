#!/bin/sh

while :
do
	xsetroot -name " $($SCRIPTS/media/rofi_mpc.sh Radio banner) | $(cpu_bar) | $(memory_bar) | $(volume_bar) | $(clock_bar) "
	sleep 1
done
