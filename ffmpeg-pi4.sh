#!/bin/sh

if [ $# -lt 3 ]; then
  LENGTH="00:01:30"
else
  LENGTH=${3}
fi
echo LENGTH=${LENGTH}
if [ $# -lt 2 ]; then
  STARTTIME="00:00:00"
else
  STARTTIME=${2}
fi
echo STARTTIME=${STARTTIME}
if [ $# -lt 1 ]; then
  echo "Usage: $0 <gamename> [start time] [length]"
  exit 1
else
  if [ -z ${4} ]; then
    ffmpeg -loglevel quiet -stats -filter_threads 4 -i temp-${1}.mp4 -ss ${STARTTIME} -t ${LENGTH} -pix_fmt yuv420p -filter:v scale=640:-1 ${1}.mp4
  else
    CROPSIZE=${4}
    echo CROPSIZE=${CROPSIZE}
    ffmpeg -loglevel quiet -stats -filter_threads 4 -i temp-${1}.mp4 -ss ${STARTTIME} -t ${LENGTH} -pix_fmt yuv420p -filter:v scale=640:-1,crop=${CROPSIZE} ${1}.mp4
  fi
  scp ${1}.mp4 pi4:/home/pi/.attract/menu-art/dc/video/
fi
