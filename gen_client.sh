#!/bin/sh

config_dir=$XDG_CONFIG_HOME/dwm
#parse the functions from header
funs="$(cat $1 | grep "{ MOD")"
names="$(printf "$funs" | awk '{print $4}' | sed "s/,//g")\n"
args="$(printf "$funs" | cut -d',' -f4- | sed "s/},//g" | sed 's/^[ \t]*//;s/[ \t]*$//' | rev | cut -c2- | rev | cut -c2- | sed 's/^[ \t]*//;s/[ \t]*$//')\n"

i=1
formatted=""
while [ $i -le $(($(printf "$args" | wc -l))) ] 
do
	name="$(printf "$names" | sed -n "$i"p)"
	arg="$(printf "$args" | sed -n "$i"p | cut -d" " -f1 | sed "s/}//g" )"
	[ ! -z "$(echo "$name" | grep '#')" ] && i=$(($i+1)) && continue
	[ "$name" = "xrdb" ] && arg=""
	[ "$arg" = "1" ] || [ "$arg" = "0" ] && arg=".i"
	arg="$(printf "$arg" | sed "s/\.//g")"
	formatted="$formatted""$name $arg\n"
	i=$(($i+1))
done
formatted="$( printf "$formatted" | sort | uniq)"

# write the client script
#which shell
printf '#!/bin/sh\n\n\n' > /tmp/dwmc

#int to mask fun
printf 'toBinaryPOSIX(){\n' >> /tmp/dwmc
printf '\tn="$((1<<$(($1-1))))"\n' >> /tmp/dwmc
printf '\techo "$n"\n' >> /tmp/dwmc
printf '}\n\n' >> /tmp/dwmc

#select arg type based on function
printf 'get_arg(){\n' >> /tmp/dwmc
printf "\t case \$1 in\n" >> /tmp/dwmc

#build fun array for config.h,
#shell function for selecting arg type
#and function for printing available functions
cases=""
fun_list=""
signals="static Signal signals [ ] = {\n\t/* signum           function */\n"
IFS='
'
printf "" > $config_dir/functions
for fun in $(printf "$formatted")
do
	metaarg="\$2"
	name="$(printf "$fun" | cut -d" " -f1)"
	type="$(printf "$fun" | cut -d" " -f2)"
	signals="$signals"'\t{ "'"$name"'"'",	$name },\n"
	[ ! -z "$(echo $name | grep "view" )" ] || [ ! -z "$(echo $name | grep "tag" )" ] && [ -z "$(echo $name | grep "shift")" ] && metaarg="\$(toBinaryPOSIX "$metaarg")"
	cases="$cases""\t\t\"$name\")\n\t\t\techo \"$type $metaarg\";;\n" 
	fun_list="$fun_list""$name, type $type\\n"
	echo $name
done
cases="$cases""\t\t\"setlayoutex\")\n\t\t\techo \"i \$2\";;\n" 
signals="$signals"'\t{ "'"setlayoutex"'"'",	setlayoutex},\n"
signals="$signals""};\n\n"
printf "$cases" >> /tmp/dwmc
printf '\tesac\n}\n\n' >> /tmp/dwmc
printf 'fun_list="'"$fun_list\n"
printf '[ "$1" = "-f" ] || [ "$1" = "--functions" ] && printf "'"$fun_list"'" && exit\n' >> /tmp/dwmc

printf 'signal() {\n\txsetroot -name "fsignal:$*"\n}\n\narg=""\n\n[ ! -z "$2" ] && arg="$(get_arg $1 $2)"\n\n' >> /tmp/dwmc
printf 'signal $1 $arg\n' >> /tmp/dwmc
chmod +x /tmp/dwmc

#replace the signals in header
linen="$(cat $1 | grep "static Signal signals" -n | cut -d":" -f1)"
printf "$signals" > /tmp/signals
cat $1 | sed '/static Signal signals\[\] = {/,/};/d' > /tmp/config
sed "$linen r /tmp/signals" "/tmp/config" > $1
sudo rm /usr/bin/dwmc
sudo cp /tmp/dwmc /usr/bin/dwmc 
