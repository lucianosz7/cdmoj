#!/bin/bash
#This file is part of CD-MOJ.

source #CONFDIR#/common.conf

cd $CACHEDIR

while true; do
	inotifywait -m $CACHEDIR -e create -e moved_to |
		while read dir action file; do
			printf "Reading"
			bash #BASEDIR#/judge/login.sh
			kill $(pgrep inotifywait)
		done < <(inotifywait)

		printf "."
		sleep 3
		continue
done
