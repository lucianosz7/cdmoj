#!/bin/bash
#This file is part of CD-MOJ.

source #CONFDIR#/common.conf

cd $HISTORYDIR

while true; do
    if (( $(ls |wc -l) == 0 )); then
		printf "."
		sleep 3
		continue
	fi
    bash #BASEDIR#/judge/login.sh
done