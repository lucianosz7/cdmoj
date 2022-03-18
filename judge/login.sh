#!/bin/bash
#This file is part of CD-MOJ.
#
#CD-MOJ is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#CD-MOJ is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with CD-MOJ.  If not, see <http://www.gnu.org/licenses/>.

source #CONFDIR#/judge.conf
source #CONFDIR#/common.conf

for arq in $CACHEDIR; do

    file="$(cat $arq)"
    
    if grep -qF "$CONTESTSDIR/$CONTEST" $file; then
        POST="$(cat $CACHEDIR/POST)"
        LOGIN="$(grep -A2 'name="login"' <<< "$POST" |tail -n1|tr -d '\n'|tr -d '\r')"
        SENHA="$(grep -A2 'name="senha"' <<< "$POST" |tail -n1|tr -d '\n'|tr -d '\r')"
        #escapar coisa perigosa
        LOGIN="$(echo $LOGIN | sed -e 's/\([[\/*]\|\]\)/\\&/g')"
        SENHA="$(echo $SENHA | sed -e 's/\([[\/.*]\|\]\)/\\&/g')"

        if ! grep -qF "$LOGIN:$SENHA:" $CONTESTSDIR/$CONTEST/passwd; then
            #invalida qualquer hash
            NOVAHASHI=$(echo "$(date +%s)$RANDOM$RANDOM" |md5sum |awk '{print $1}')
            printf "$NOVAHASHI" > "$CACHEDIR/$LOGIN-$CONTEST"

            printf "$CONTEST:$LOGIN:failed" > "$CACHEDIR/$CONTEST:$LOGIN:failed"
        fi

        NOVAHASH=$(echo "$(date +%s)$RANDOM$LOGIN" |md5sum |awk '{print $1}')
        printf "$NOVAHASH" > "$CACHEDIR/$LOGIN-$CONTEST"

        #avisa do login
        touch  $SUBMISSIONDIR/$CONTEST:$AGORA:$RAND:$LOGIN:login:dummy

    else 
        exit 0
    fi
done