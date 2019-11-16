#!/bin/bash

. ./settings

echo -n "Cleaning up local directory... "
rm -f *.lpl
echo "done."

echo -n "Cleaning up remote directory on Pi4... "
ssh root@$PI_IP "rm -f playlists/*.lpl" > /dev/null
echo "done."

CONSOLELIST=$(ssh root@$PI_IP "ls -1 $PI_ROMPATH/" | tr -d $'\r' | sed -e 's/\/$//')

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

  GAMELIST=$(ssh root@$PI_IP "ls -1 $PI_ROMPATH/$CONSOLE/ | tr ' ' '_' | tr -d $'\r'")
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
      FULLPATH=$(echo $PI_ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
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
scp *.lpl root@$PI_IP:playlists/ > /dev/null
echo "done"

exit 0
