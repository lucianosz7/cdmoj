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
    LASTFILE="$(ls -t $CACHEDIR/ | head -n1)"
    LOGIN="$(grep -F "$CONTEST:"  $CACHEDIR/$LASTFILE | grep : | cut -d : -f2)"
    LOGIN="$(echo $LOGIN | sed -e 's/\([[\/*]\|\]\)/\\&/g')"

    printf "$NEW" > "$CACHEDIR/$LOGIN-$CONTEST:tmp"

    if ! grep -qF "$LOGIN:$NEW:" $CONTESTSDIR/$CONTEST/passwd; then
      #if ! find /cdmoj-dev/ -name ".htpasswd"; then
      if ( shopt -s nullglob; set -- $CACHEDIR/*.htpasswd; (( $# > 0)) ) && true || false; then
        htpasswd -ciB $CACHEDIR/.htpasswd $LOGIN < $CACHEDIR/$LOGIN-$CONTEST:tmp
      else
        htpasswd -Bi $CACHEDIR/.htpasswd $LOGIN < $CACHEDIR/$LOGIN-$CONTEST:tmp
      fi
      printf "$CONTEST:$LOGIN:AccessPermited" > "$CACHEDIR/$CONTEST:$LOGIN:ACCESS"
      sed -i 's/.*$CONTEST:$LOGIN::firstAccess.*/$CONTEST:$LOGIN:AccessPermited/' $CACHEDIR/$CONTEST:$LOGIN
    fi
else 
    exit 0
fi

  #enviar cookie
  ((ESPIRA= AGORA + 36000))
  printf "Content-type: text/html\n\n"
  cat << EOF
  <script type="text/javascript">
    document.cookie="login=$LOGIN; expires=$(date --utc --date=@$ESPIRA); Path=/"
    document.cookie="hash=$NEW; expires=$(date --utc --date=@$ESPIRA); Path=/"
    top.location.href = "$BASEURL/cgi-bin/contest.sh/$CONTEST"
  </script>
EOF
  exit 0