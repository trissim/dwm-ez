#!/bin/sh
pkill sxhkd
sxhkd -c $XDG_CONFIG_HOME/dwm/sxhkdrc &
[ -z "$(pgrep -x "picom")" ] && picom --experimental-backend &
[ -z "$(pgrep -x "mpd")" ] && mpd
[ -z "$(pgrep -x "dwmstatus.sh")" ] && $XDG_CONFIG_HOME/dwm/dwmstatus.sh
dwmc xrdb
