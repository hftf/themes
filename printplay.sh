function midplay {
	fluidsynth -g1 -i /usr/local/share/fluidsynth/gs_sf_144.sf2 "$@" > /dev/null 2>&1 &
}

id=$1

grep ^$id tsvs/themes.tsv
midplay midis/$id.mid
