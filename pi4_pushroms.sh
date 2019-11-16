#!/bin/bash

. ./settings

MAME2k10ROMDIR=$GAMESDIR/mame2010/
FBAROMDIR=$GAMESDIR/fbneo/

if [ $# -lt 1 ]
  then
    echo "Usage: $0 <MAME driver>" 
    exit 1
fi

push_game () {
  GAMENAME=$(basename $2 .zip)
  FULLNAME=$($MAMEBIN -listfull "$GAMENAME" | grep -v "Description" | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  printf "%-10s%-10s%-60s\n" "$1" "$GAMENAME" "$FULLNAME"
  scp -q $2 root@$PI_IP:$PI_ROMPATH/$1/$2
}

while [ $# -ne 0 ]
do
  if $(ssh root@$PI_IP "test -f $PI_ROMPATH/*/$1.zip"); then
    echo "Game $1 already present, skipping"
  else
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
          if [ "$DRIVERNAME" = "neogeo" ] || [ "$DRIVERNAME" = "cps2" ] || [ "$DRIVERNAME" = "cps3" ]
          then
            cd $FBAROMDIR/
            push_game fbneo $GAME.zip
          elif [ -f $MAME2k10ROMDIR/$GAME.zip ]
          then
            cd $MAME2k10ROMDIR/
            push_game mame2010 $GAME.zip
          elif [ -f $FBAROMDIR/$GAME.zip ]
          then
            cd $FBAROMDIR/
            push_game fbneo $GAME.zip
          fi
        fi
        done <<< $DRIVERGAMES
    fi
  fi
  shift
done