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
    echo -n "Pushing $2 to Picade in folder $1 ... "
    rsync -e ssh -avzq --progress $2 pi@$PI_IP:$PI_ROMPATH/$1/$2
    echo "done"
}

while [ $# -ne 0 ]
do
  GAMES=$($MAMEBIN -listfull | awk '{print $1}' | sort | uniq)
  if ! echo $GAMES | grep -q -w $1  
  then
    $MAMEBIN -listfull $1
  else
    DRIVERNAME=$($MAMEBIN -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    echo -n "Driver for game $1 is $DRIVERNAME, retrieving all games for this driver... "
    DRIVERGAMES=$($MAMEBIN -listsource | grep -w "$DRIVERNAME" | awk '{print $1}')
    echo "done"

    while IFS= read -r GAME
    do
      CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
      if ! echo $CLONES | grep -q -w $GAME
      then
        if [ "$DRIVERNAME" = "neogeo" ] || [ "$DRIVERNAME" = "cps2" ] || [ "$DRIVERNAME" = "cps3" ]
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
