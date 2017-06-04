function midplay {
	fluidsynth -g1 -i /usr/local/share/fluidsynth/gs_sf_144.sf2 "$@" > /dev/null 2>&1 &
}

function pronounce {
	sed "
	s/Adam/a dom/;
	s/Auber/obay/;
	s/Balakirev/baaluh keerev/;
	s/Buxtehude/books tahooda/;
	s/Chausson/show son/;
	s/Debussy/[[inpt PHON]]dEHbyUWs1IY[[inpt TEXT]]/;
	s/Delius/[[inpt PHON]]dIYlIYUXs[[inpt TEXT]]/;
	s/D'Indy/dan dee/;
	s/Falla/[[inpt PHON]]fAYAX[[inpt TEXT]]/;
	s/Franck/fronk/;
	s/Ibert/ee bear/;
	s/Lekeu/lakoo/;
	s/Lully/loo lee/;
	s/Malipiero/molly pee arrow/;
	s/Milhaud/me yo/;
	s/Pierné/peair nay/;
	s/Prokofiev/prokofee'ev/;
	s/Ravel/[[inpt PHON]]rAX1vEH0l[[inpt TEXT]]/;
	s/Roussel/[[inpt PHON]]rUWs1EHl[[inpt TEXT]]/;
	s/Scriabin/Scriaabin/;
	s/Sousa/sooza/;
	s/Suppé/suepay/;
	s/Tartini/[[inpt PHON]]tAArt1IYnIH[[inpt TEXT]]/;
	s/Vieuxtemps/[[inpt PHON]]vyUHht1AAm[[inpt TEXT]]/;
	s/Walton/[[inpt PHON]]wAOltAHn[[inpt TEXT]]/;
	s/Waldteufel/vald toyfl/;
	s/Weber/Vaber/;
	s/Wolf$/voulf/"
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
		grep ^$id tsvs/known.tsv | cut -f 2
		echo "$info"
		# echo "$last" | pronounce | say -r 240
	fi
	replay=true
	status="0"
	while [ "$replay" = "true" ]; do
		replay=false
		midplay midis/$id.mid
		pid="$!"
		read -p "Add? [Y]es [m]aybe [N]o   [L]ink [o]pen   [p]rint [s]peak l[a]st   [R]eplay s[k]ip [Q]uit " -n 1 -r
		echo
		{ kill "$pid"; wait "$pid"; } 2>/dev/null
		case $REPLY in
		[yY])
			status="y"
			;;
		[mM])
			status="m"
			;;
		[nN])
			status="n"
			;;

		[lL])
			read -p "Enter YouTube link? " -r
			# find line starting with $id
			# then add $REPLY at the end of the line
			sed -i bak "/^$id	/ s|$|	$REPLY|" tsvs/themes.tsv
			replay=true
			;;
		[oO])
			if [ -n "$yt" ]; then
				open "$yt"
			fi
			replay=true
			;;

		[pP])
			echo "$info"
			replay=true
			;;
		[sSjJ])
			echo "$last; $theme" | pronounce | say -r 350
			replay=true
			;;
		[aAuU])
			echo "$last" | pronounce | say -r 240
			replay=true
			;;

		[kK])
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

	if [ "$status" = "0" ]; then
		echo
		continue
	fi

	if [ "$recall" = "0" ]; then
		# add to known.tsv
		echo "$id	$status" >> tsvs/known.tsv
	else
		echo "$info"
	fi

	sleep 0.5
	echo
done
