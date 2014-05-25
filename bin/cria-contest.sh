#!/bin/bash

source #CONFDIR#/common.conf

NEWCONTEST="$1"
ADMINLOGIN="$2"
CONTESTDESC="$1/contest-description.txt"

if (( $# != 2 )); then
    echo "$0 path/to/contest-description.txt adminlogin"
    echo "    check file format"
    exit 0
fi

if [[ ! -e "$CONTESTDESC" ]]; then
    echo "\"$CONTESTDESC\": file not found"
    exit 0
fi

#if [[ ! -d "$CONTESTSDIR" ]]; then
#    echo "\"$CONTESTSDIR\": Directory not fount"
#    exit 0
#fi

CONTEST_ID=
CONTEST_NAME=
ALLPROBS=
USUARIOS=
VARIAVEISADICIONAIS=
{
    read CONTEST_ID
    read CONTEST_NAME
    read CONTEST_START
    read CONTEST_END
    read PROBCOUNT
    for((i=0;i<PROBCOUNT;i++)); do
        read PROBDESC
        ALLPROBS=( "${ALLPROBS[@]}" "$PROBDESC" )
    done

    read USUARIOSCOUNT
    for((i=0;i<USUARIOSCOUNT;i++)); do
        read LINHA
        USUARIOS="$USUARIOS$LINHA\n"
    done
    while read LINE; do
      VARIAVEISADICIONAIS="$VARIAVEISADICIONAIS $LINE"
    done
} < "$CONTESTDESC"

if [[ -d "$CONTESTSDIR/$CONTEST_ID" ]] &&
      [[ -e "$CONTESTSDIR/$CONTEST_ID/owner" ]] &&
      [[ "$ADMINLOGIN" != "$(< $CONTESTSDIR/$CONTEST_ID/owner)" ]]; then
    printf "$CONTEST_ID já existe e donos diferem, abortando\n"
    exit 1
fi
mkdir "$CONTESTSDIR/$CONTEST_ID"

for i in controle data enunciados submissions; do
    mkdir -p "$CONTESTSDIR/$CONTEST_ID/$i"
done

#data of users must be writabble by www-data
chmod go+rwx "$CONTESTSDIR/$CONTEST_ID/data"

{
    echo "CONTEST_ID=$CONTEST_ID"
    echo "CONTEST_NAME=$CONTEST_NAME"
    echo "CONTEST_START=$CONTEST_START"
    echo "CONTEST_END=$CONTEST_END"
    echo "PROBS=(${ALLPROBS[@]})"
    for VAR in $VARIAVEISADICIONAIS; do
      echo "$VAR"
    done
} > $CONTESTSDIR/$CONTEST_ID/conf

printf "$USUARIOS" > $CONTESTSDIR/$CONTEST_ID/passwd

if [[ -d "$NEWCONTEST/enunciados" ]]; then
    #copia enunciados para html
    mkdir -p $HTMLDIR/contests/$CONTEST_ID/
    rsync -a --delete $NEWCONTEST/enunciados/ $HTMLDIR/contests/$CONTEST_ID/
    rsync -a --delete $NEWCONTEST/enunciados/ $CONTESTSDIR/$CONTEST_ID/enunciados/
    chmod a+rX -R $NEWCONTEST/enunciados/* $HTMLDIR/contests/$CONTEST_ID/
fi

#gravar dono no CONTEST
echo "$ADMINLOGIN" > $CONTESTSDIR/$CONTEST_ID/owner

DROPBOXDIR="$HOME/Dropbox/cd-moj/admins/cd-moj-$ADMINLOGIN-contests"
mkdir -p "$DROPBOXDIR"
if [[ ! -e "$DROPBOXDIR/$CONTEST_ID" ]]; then
  ln -s $CONTESTSDIR/$CONTEST_ID "$DROPBOXDIR"
fi

echo "$CONTEST_ID criado com sucesso"

exit 0
