#!/bin/sh

if [ $# -lt 1 ];
then
  echo "Usage: $0 <gamename> [seconds]"
  exit 1
fi

if [ $# -lt 2 ];
then
  SECONDS="00:00:00"
else
  SECONDS="00:00:$2"
fi

if [ ! -f ./temp-$1.mp4 ]; then
  wget -c http://www.progettosnaps.net/videosnaps/mp4/$1.mp4 -O temp-$1.mp4
fi
if [ -f ./temp-$1.mp4 ]; then
  ffmpeg -loglevel quiet -stats -i temp-$1.mp4 -ss "$SECONDS" -t 00:01:30 -b:v 512k -pix_fmt yuv420p $1.mp4
  rm temp-$1.mp4
fi
if [ -f ./$1.mp4 ]; then
  scp $1.mp4 pi4:/home/pi/.attract/menu-art/dc/video/$1.mp4
#  rm $1.mp4
fi
