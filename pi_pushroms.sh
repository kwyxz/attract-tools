#!/bin/bash

. ./settings

MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBAROMDIR=$GAMESDIR/fba/

if [ $# -lt 1 ]
  then
    echo "Usage: $0 <MAME driver>" 
    exit 1
fi

push_game () {
    GAMENAME=$(basename $2 .zip)
    FULLNAME=$($MAMEBIN -listfull "$GAMENAME" | grep -v "Description" | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
    printf "%-10s%-10s%-60s\n" "$1" "$GAMENAME" "$FULLNAME"
    rsync -e ssh -avzq --progress $2 pi@$PI_IP:$PI_ROMPATH/$1/$2
}

while [ $# -ne 0 ]
do
  GAMES=$($MAMEBIN -listfull | awk '{print $1}' | sort | uniq)
  if ! echo $GAMES | grep -q -w $1  
  then
    $MAMEBIN -listfull $1
  else
    DRIVERNAME=$($MAMEBIN -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    echo "$1 parent driver = $DRIVERNAME"
    DRIVERGAMES=$($MAMEBIN -listsource | grep -w "$DRIVERNAME" | awk '{print $1}')

    while IFS= read -r GAME
    do
      CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
      if ! echo $CLONES | grep -q -w $GAME
      then
#        if [ "$DRIVERNAME" = "neogeo" ] || [ "$DRIVERNAME" = "cps2" ] || [ "$DRIVERNAME" = "cps3" ]
        if [ "$DRIVERNAME" = "cps3" ]
        then
          cd $FBAROMDIR/
          push_game fba $GAME.zip
        elif [ -f $MAME2k3ROMDIR/$GAME.zip ]
        then
          cd $MAME2k3ROMDIR/
          push_game mame2003 $GAME.zip
        elif [ -f $FBAROMDIR/$GAME.zip ]
        then
          cd $FBAROMDIR/
          push_game fba $GAME.zip
        fi
      fi
      done <<< $DRIVERGAMES
  fi
  shift
done
