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
  touch "$CACHEDIR/POST"
  touch "$POST" > "$CACHEDIR/POST"
  touch "$CACHEDIR/$CONTESTSDIR:$CONTEST"
  touch "$CONTESTSDIR/$CONTEST" > "$CACHEDIR/$CONTESTSDIR:$CONTEST"
  
  if grep -qF "$CONTEST:$LOGIN:failed" $CACHEDIR/$CONTEST:$LOGIN:failed; then
    cabecalho-html
    cat << EOF
  <script type="text/javascript">
    window.alert("Senha Incorreta");
    top.location.href = "$BASEURL/cgi-bin/contest.sh/$CONTEST"
  </script>
EOF
    exit 0
  fi
  
  HASH="$(cat $CACHEDIR/$LOGIN-$CONTEST)"

  #enviar cookie
  ((ESPIRA= AGORA + 36000))
  printf "Content-type: text/html\n\n"
  cat << EOF
  <script type="text/javascript">
    document.cookie="login=$LOGIN; expires=$(date --utc --date=@$ESPIRA); Path=/"
    document.cookie="hash=$HASH; expires=$(date --utc --date=@$ESPIRA); Path=/"
    top.location.href = "$BASEURL/cgi-bin/contest.sh/$CONTEST"
  </script>
EOF
  exit 0

elif verifica-login $CONTEST |grep -q Nao; then
  tela-login $CONTEST
fi

#printf "Location: /~moj/cgi-bin/contest.sh/$CONTEST\n\n"
  printf "Content-type: text/html\n\n"
  cat << EOF
  <script type="text/javascript">
    top.location.href = "$BASEURL/cgi-bin/contest.sh/$CONTEST"
  </script>
EOF
exit 0