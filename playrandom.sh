function midplay {
	fluidsynth -g1 -i /usr/local/share/fluidsynth/gs_sf_144.sf2 "$@" > /dev/null 2>&1 &
}

CC='\033[0;97;41m'
BC='\033[1m'
UC='\033[4m'
NC='\033[0m'

case "$1" in
	y)
		recall="y"
		;;
	n)
		recall="n"
		;;
	*)
		recall="0"
		;;
esac

while true; do
	if [ "$recall" = "0" ]; then
		# random sample of all themes
		line=`gshuf -n 1 tsvs/themes.tsv`
	else
		# random sample of themes where known = $recall
		line=$(eval "grep $recall\$ tsvs/known.tsv | gshuf -n 1")
		# get the id
		IFS=$'\t' read lid yn <<< "$line"
		# join on id
		line=$(eval "grep ^$lid\ tsvs/themes.tsv")
		echo $line
	fi

	IFS=$'\t' read id last first theme yt <<< "$line"
	info=$(printf "%-6s   %-48b   %s	%b\n" "[$id]" "${CC} $first ${BC}$last ${NC}" "$theme" "${UC}$yt${NC}")
	if [ "$recall" = "0" ]; then
		echo "$info"
		say "$last"
	fi
	replay=true
	while [ "$replay" = "true" ]; do
		replay=false
		midplay midis/$id.mid
		pid="$!"
		read -p "Add? [Y]es [m]aybe [N]o [p]rint [s]peak [R]eplay [Q]uit " -n 1 -r
		echo
		{ kill "$pid"; wait "$pid"; } 2>/dev/null
		case $REPLY in
		[yY])
			status="y"
			;;
		[mM])
			status="m"
			;;
		[sS])
			say -r 350 "$last; $theme"
			replay=true
			;;
		[pP])
			echo "$info"
			replay=true
			;;
		[nN])
			status="n"
			;;
		[qQ])
			echo
			break 2
			;;
		*)
			replay=true
			;;
		esac

	done
	if [ "$recall" = "0" ]; then
		# add to known.tsv
		echo "$id	$status" >> tsvs/known.tsv
	else
		echo "$info"
	fi
	sleep 0.5
	echo
done
