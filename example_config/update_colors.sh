#!/bin/sh

normbordercolor=1
normbgcolor=1
normfgcolor=3
selbordercolor=2
selbgcolor=2
selfgcolor=1
colors="$(cat ~/.cache/wal/colors)"
ncolors="$(cat ~/.cache/wal/colors | wc -l)"
i=1
while [ $i -le $(($ncolors)) ]
do
	color="$(printf "$colors" | sed -n "$i"p)"
	[ $i -eq $(($normbordercolor)) ] && echo "dwm.normbordercolor:	$color" | xrdb -merge 
	[ $i -eq $(($normbgcolor)) ] && echo "dwm.normbgcolor:	$color" | xrdb -merge 
	[ $i -eq $(($normfgcolor)) ] && echo "dwm.normfgcolor:	$color" | xrdb -merge 
	[ $i -eq $(($selbordercolor)) ] && echo "dwm.selbordercolor:	$color" | xrdb -merge 
	[ $i -eq $(($selbgcolor)) ] && echo "dwm.selbgcolor:	$color" | xrdb -merge 
	[ $i -eq $(($selfgcolor)) ] && echo "dwm.selfgcolor: $color" | xrdb -merge 
	i=$(($i+1))
done
dwmc xrdb
