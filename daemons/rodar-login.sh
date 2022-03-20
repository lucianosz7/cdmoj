
#!/bin/bash
#This file is part of CD-MOJ.

source #CONFDIR#/common.conf

cd $CACHEDIR

while true; do
    if (( $(ls |wc -l) == 4 )); then
		printf "."
		sleep 3
		continue
	fi
    bash #BASEDIR#/judge/login.sh
done