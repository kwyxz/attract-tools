#!/usr/bin/env sh

for fich in $(ssh pi4 "ls -1 /home/pi/.attract/menu-art/arcade/video/*.mp4"); do
  game=$(basename $fich .mp4)
  wget -c http://www.progettosnaps.net/videosnaps/mp4/$game.mp4 -O nommal-$game.mp4
  if [ -f nommal-$game.mp4 ]; then
    ffmpeg -y -loglevel quiet -stats -i nommal-$game.mp4 -pix_fmt yuv420p $game.mp4
    if [ -f $game.mp4 ]; then
      rsync -e ssh -av $game.mp4 pi4:/home/pi/.attract/menu-art/arcade/video/
    fi
  fi
# rm -f nommal-$game.mp4 $game.mp4
done
