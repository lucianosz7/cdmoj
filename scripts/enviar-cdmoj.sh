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

#ARQFONTE=arquivo-com-a-fonte
#PROBID=id-do-problema
MOJPORTS=(20000 40000 20001 40000)

function login-cdmoj()
{
  true
  if [[ ! -e /tmp/mojports ]]; then
    for PORT in ${MOJPORTS[@]}; do
      if echo '{ "cmd": "null" }'| nc -w 1 localhost $PORT &>/dev/null; then
        echo $PORT >> /tmp/mojports
      fi
    done
  fi
}

#retorna o ID da submissao
function enviar-cdmoj()
{
  local PORTS
  declare -a PORTS
  readarray -t PORTS < /tmp/mojports
  local PORT
  PORT=${PORTS[0]}
  unset PORTS[0]
  PORTS+=( $PORT )
  rm /tmp/mojports
  for p in ${PORTS[@]}; do
	  echo $p >> /tmp/mojports
  done

  local ARQFONTE=$1
  local PROBID=$2
  local LINGUAGEM=$(echo $3|tr '[A-Z]' '[a-z]')
  #CODIGO=$(cut -d: -f3 <<< "$ARQFONTE")
  local TEMP=$(mktemp)
  #ssh mojjudge@mojjudge.naquadah.com.br "bash autojudge-sh.sh $LINGUAGEM $PROBID $CODIGO" < "$ARQFONTE"
  cat << EOF > $TEMP
{ "cmd": "run", "problemid": "$PROBID", "language": "$LINGUAGEM", "filename": "Main.$LINGUAGEM", "fileb64": "$(base64 -w 0 $ARQFONTE)", "metadata": "$ARQFONTE" }
EOF
  cat $TEMP >&2
  cat $TEMP |nc localhost $PORT | base64 -d|gunzip| jshon -e jobid |tr -d '"' > $TEMP.a
  CODIGO=$(<$TEMP.a)
  echo "$PORT.$CODIGO"
  echo "$PORT.$CODIGO" >&2
  echo "=== $CODIGO" >&2
  rm $TEMP.a $TEMP
  ## Gambiarra horrível
  local COMPETICAO="$(basename $ARQFONTE|cut -d: -f1)"
  local LOCALID="$(basename $ARQFONTE|cut -d: -f2,3)"
  mkdir -p $HOME/contests/$COMPETICAO/mojlog/
  echo "localhost $PORT $CODIGO" >> $HOME/contests/$COMPETICAO/mojlog/$LOCALID
}

#Retorna string do resultado
function pega-resultado-cdmoj()
{
  local PORT=$(echo $1 |cut -d '.' -f1)
  local JOBID=$(echo $1|cut -d '.' -f2)
  local TEMP=$(mktemp)
  local COUNT=0
  echo "{ \"cmd\": \"getresult\", \"jobid\": \"$JOBID\" }"| nc localhost $PORT| base64 -d|gunzip |jshon -e status|tr -d '"' > $TEMP
  echo "($PORT) { \"cmd\": \"getresult\", \"jobid\": \"$JOBID\" }" >&2
  RESULT="$(<$TEMP)"
  while (( COUNT < 15 )) && ( [[ "$RESULT" == "On queue" ]] || [[ "$RESULT" == "Running" ]] ); do
    sleep 5
    echo "{ \"cmd\": \"getresult\", \"jobid\": \"$JOBID\" }"| nc localhost $PORT|base64 -d|gunzip |jshon -e status|tr -d '"' > $TEMP
    RESULT="$(<$TEMP)"
    ((COUNT++))
  done
  echo "$RESULT"
  rm $TEMP
}
