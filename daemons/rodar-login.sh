#!/bin/bash
#This file is part of CD-MOJ.

source #CONFDIR#/common.conf

cd $CACHEDIR || return 

while true; do
	ls -A > "$CACHEDIR/oldFiles"
	if [[ -e $CACHEDIR/newFiles ]]; then
		continue
    else
		touch "$CACHEDIR/newFiles"
	fi

	DIRDIFF=$(diff "$CACHEDIR/oldFiles" "$CACHEDIR/newFiles" | cut -f 2 -d "")

    if ! $DIRDIFF; then
		printf "."
		sleep 3
		continue
	fi
    bash #BASEDIR#/judge/login.sh
done
