#!/bin/bash

. ./settings

echo -n "Cleaning up local directory... "
rm -f *.lpl
echo "done."

echo -n "Cleaning up remote directory on Pi4... "
ssh root@$PI_IP "rm playlists/*" > /dev/null
echo "done."

CONSOLELIST=$(ssh $PI_IP "ls $PI_ROMPATH ; ls -1 " | tr -d $'\r' | sed -e 's/\/$//')

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$($MAMEBIN -listfull "$MAMEGAME" | grep -v Description | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  if [[ ! -z "$FULLNAME" ]]; then
    echo -n .
  else
    PLAYLIST=""
  fi
}

_getname ()
{
  if $(echo "$1" | grep -q "$2")
  then
    GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
    if $(echo "$GAME" | grep -q \.zip)
    then
      FULLNAME=$(basename "$GAME" "$2.zip")
    else
      FULLNAME=$(basename "$GAME" "$2")
    fi
  else
    echo "$1" has an unrecognized extension, skipping
    SKIP=1
  fi
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  COMMAND="open -u anonymous,blah $VITA_IP:$VITA_PORT ; cd /$ROMPATH/$CONSOLE/ ; cls -1 "
  GAMELIST=$(lftp -c "$COMMAND" | tr ' ' '_' | tr -d $'\r')
  FULLNAME=""

  for GAMENAME in $GAMELIST
  do
  SKIP=0
    case $CONSOLE in
      fbneo|neogeo|cps[1-2])
        PLAYLIST="FBNeo - Arcade Games.lpl"
        LIBRETRO="/usr/lib/libretro/fbneo_libretro.so"
        LIBNAME="FBNeo"
        _mame "$GAMENAME"
        ;;
      mame2010)
        PLAYLIST="MAME 2010.lpl"
        LIBRETRO="/usr/lib/libretro/mame2010_libretro.so"
        LIBNAME="MAME 2003"
        _mame "$GAMENAME"
        ;;
      *)
        PLAYLIST=""
        echo "Hardware $CONSOLE is not supported."
        ;;
    esac

  if [[ ! -z $PLAYLIST ]]
  then
    if [[ $SKIP -eq 0 ]]
    then
      FULLPATH=$(echo $ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
      CRC32="00000000"
      echo "$FULLPATH" >> "$PLAYLIST"
      echo "$FULLNAME" >> "$PLAYLIST"
      echo "$LIBRETRO" >> "$PLAYLIST"
      echo "$LIBNAME" >> "$PLAYLIST"
      echo "$CRC32|crc" >> "$PLAYLIST"
      echo "$PLAYLIST" >> "$PLAYLIST"
      echo -n .
    fi
  fi

  done
echo
done

echo -n "Uploading playlists to Pi4... "
scp *.lpl $PI_IP:playlists/ > /dev/null
echo "done"

exit 0
