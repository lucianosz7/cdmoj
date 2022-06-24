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

source common.sh

POST="$(cat )"
AGORA="$(date +%s)"
CAMINHO="$PATH_INFO"
CONTEST="$(cut -d'/' -f2 <<< "$CAMINHO")"
CONTEST="${CONTEST// }"

if [[ "x$POST" != "x" ]]; then
    OLD="$(grep -A2 'name="oldPasswd"' <<< "$POST" |tail -n1|tr -d '\n'|tr -d '\r')"
    OLD="$(echo $OLD | sed -e 's/\([[\/*]\|\]\)/\\&/g')"
    NEW="$(grep -A2 'name="newPasswd"' <<< "$POST" |tail -n1|tr -d '\n'|tr -d '\r')"
    NEW="$(echo $NEW | sed -e 's/\([[\/*]\|\]\)/\\&/g')"
    LASTFILE ="$(ls -t $CACHEDIR/ | head -n1)"
    printf "$(ls -t $CACHEDIR/)" >  $CACHEDIR/LAST
    LOGIN="$(grep -F "$CONTEST:"  $CACHEDIR/$LASTFILE | grep : | cut -d : -f2)"
    LOGIN="$(echo $LOGIN | sed -e 's/\([[\/*]\|\]\)/\\&/g')"

    printf "$LASTFILE:$LOGIN:$NEW" > "$CACHEDIR/$LOGIN-$CONTEST"

else 
    exit 0
fi

  printf "Content-type: text/html\n\n"
  cat << EOF
  <script type="text/javascript">
    top.location.href = "$BASEURL/cgi-bin/contest.sh/$CONTEST"
  </script>
EOF
exit 0