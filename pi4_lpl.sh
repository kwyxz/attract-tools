#!/bin/bash

. ./settings

echo -n "Cleaning up local directory... "
rm -f *.lpl
echo "done."

echo -n "Cleaning up remote directory on Pi4... "
ssh $PI4_USER@$PI4_IP "rm -f playlists/*.lpl" > /dev/null
echo "done."

CONSOLELIST=$(ssh $PI4_USER@$PI4_IP "ls -1 $PI4_ROMPATH/" | tr -d $'\r' | sed -e 's/\/$//')

_mame ()
{
  MAMEGAME=$(basename $1 .zip)
  FULLNAME=$($MAMEBIN -listfull "$MAMEGAME" | grep -v Description | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  if [[ ! -z "$FULLNAME" ]]; then
    echo -n .
  else
    echo "Game $1 was skipped!"
    SKIP=1
  fi
}

_fbneo ()
{
  FULLNAME=$(grep -B4 name\ $1 $FBNEODB | grep name\ \" | cut -d '"' -f 2)
  if [[ ! -z "$FULLNAME" ]]; then
    echo -n .
  else
    _mame "$1"
  fi
}

_getname ()
{
  case $3 in
    fbneo|neogeo|cps[12])
      _fbneo "$1"
      ;;
    mame*)
      _mame "$1"
      ;;
    *)
      if $(echo "$1" | grep -q "$2"); then
        GAME=$(echo "$1" | tr '_' ' ' | tr -d '[!]')
        if $(echo "$GAME" | grep -q \.zip); then
          FULLNAME=$(basename "$GAME" "$2.zip")
        else
          FULLNAME=$(basename "$GAME" "$2")
        fi
      else
        echo "$1" has an unrecognized extension, skipping
        SKIP=1
      fi
      ;;
  esac
}

_init_lpl ()
{
  echo -e "{\n  \"version\": \"1.2\",\n  \"default_core_path\": \"$2\",\n  \"default_core_name\": \"$3\",\n  \"items\": [" > "$1"
}

_add_game_to_json ()
{
  echo -e "    {\n      \"path\": \"$1\",\n      \"label\": \"$2\",\n      \"core_path\": \"$3\",\n      \"core_name\": \"$4\",\n      \"crc32\": \"$5|crc\",\n      \"db_name\": \"$6\"\n    }," >> "$6"
}

_close_lpl ()
{
  echo -e "  ]\n}" >> "$1"
}

for CONSOLE in $CONSOLELIST
do
  echo Generating playlist for : $CONSOLE

  GAMELIST=$(ssh $PI4_USER@$PI4_IP "ls -1 $PI4_ROMPATH/$CONSOLE/ | tr ' ' '_' | tr -d $'\r'")
  FULLNAME=""

  case $CONSOLE in
    fbneo|neogeo|cps[1-2])
      PLAYLIST="FBNeo - Arcade Games.lpl"
      LIBRETRO="/usr/lib/libretro/fbneo_libretro.so"
      LIBNAME="FBNeo"
      ;;
    mame2003)
      PLAYLIST="MAME.lpl"
      LIBRETRO="/usr/lib/libretro/mame2010_libretro.so"
      LIBNAME="MAME"
      ;;
    naomi)
      PLAYLIST="Sega - NAOMI.lpl"
      LIBRETRO="/usr/lib/libretro/flycast_libretro.so"
      LIBNAME="Flycast"
      ;;
    neocd)
      PLAYLIST="SNK - Neo Geo CD.lpl"
      LIBRETRO="/usr/lib/libretro/fbneo_libretro.so"
      LIBNAME="FBNeo"
      ;;
    *)
      PLAYLIST=""
      echo "Hardware $CONSOLE is not supported."
      ;;
  esac

  _init_lpl "$PLAYLIST" "$LIBRETRO" "$LIBNAME"

  for GAMENAME in $GAMELIST
  do
    SKIP=0

    _getname "$GAMENAME" "$EXTENSION" "$CONSOLE"

    if [[ ! -z "$PLAYLIST" ]]
    then
      if [[ $SKIP -eq 0 ]]
      then
        FULLPATH=$(echo $PI4_ROMPATH/$CONSOLE/$GAMENAME | tr '_' ' ')
        CRC32="00000000"
        _add_game_to_json "$FULLPATH" "$FULLNAME" "$LIBRETRO" "$LIBNAME" "$CRC32" "$PLAYLIST"
        echo -n .
      fi
    fi

  done

  _close_lpl "$PLAYLIST"
  echo

done

echo -n "Uploading playlists to Pi4... "
scp *.lpl $PI4_USER@$PI4_IP:playlists/ > /dev/null
echo "done"

exit 0
