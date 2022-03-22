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
done
