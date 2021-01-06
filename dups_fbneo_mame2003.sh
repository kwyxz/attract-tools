#!/usr/bin/env sh

. settings

for fich in $(ssh pi4 "ls -1 /home/pi/roms/mame2003")
do
  GAME=$(basename ${fich} .zip)
  if [ -f $GAMESDIR/fbneo/$GAME.7z ]; then
    echo $GAME
  fi
done
