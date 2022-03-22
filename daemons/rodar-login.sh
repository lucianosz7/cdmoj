#!/bin/bash
#This file is part of CD-MOJ.

source #CONFDIR#/common.conf

cd $CACHEDIR

while true; do
	inotifywait -m $CACHEDIR -e create -e moved_to |
		while read dir action file; do
			bash #BASEDIR#/judge/login.sh
		done
		
		printf "."
		sleep 3
		continue
	#ls -A > "$CACHEDIR/oldFiles"
	#if [[ -e $CACHEDIR/newFiles ]]; then
	#	continue
    #fi
	#touch "$CACHEDIR/newFiles"

	#DIRDIFF=$(diff "$CACHEDIR/oldFiles" "$CACHEDIR/newFiles" | cut -f 2 -d "")

    #if diff "$CACHEDIR/oldFiles" "$CACHEDIR/newFiles" | cut -f 2 -d ""; then
	#	printf "."
	#	sleep 3
	#	continue
	#fi
    #bash #BASEDIR#/judge/login.sh
done
