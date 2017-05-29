function midplay {
	fluidsynth -g1 -i /usr/local/share/fluidsynth/gs_sf_144.sf2 "$@" > /dev/null 2>&1 &
}

CC='\033[0;97;41m'
BC='\033[1m'
UC='\033[4m'
NC='\033[0m'

while true; do
	line=`gshuf -n 1 tsvs/themes.tsv`
	IFS=$'\t' read id last first theme yt <<< "$line"
	printf "%-6s   %-48b   %s	%b\n" "[$id]" "${CC} $first ${BC}$last ${NC}" "$theme" "${UC}$yt${NC}"
	say "$last"
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
		echo "$status	$id" >> tsvs/known.tsv
	done
	sleep 0.5
	echo
done
