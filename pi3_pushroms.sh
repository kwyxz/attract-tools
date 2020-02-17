#!/bin/bash

. ./settings

MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBNEOROMDIR=$GAMESDIR/fbneo/
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)

usage() {
  echo -e "\033[0;33mUsage\033[0m: $0 <MAME gamename>"
  exit 1
}

die() {
  echo -e "\033[0;31mERROR\033[0m: $1"
  exit 1
}

is_clone() {
  return $(echo ${CLONES} | grep -q -w ${1})
}

is_present() {
  return $(ssh ${PI3_USER}@${PI3_IP} "test -f ${PI3_ROMPATH}/*/$1.zip")
}

print_fullname() {
  FULLNAME=$(${MAMEBIN} -listfull "$2" | grep -v "Description" | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
  printf "%-10s\e[1;32m%-10s\e[0m%-60s\n" "$1" "$2" "$FULLNAME"
}

push_game() {
  if is_present "$2"; then
    printf "%-10s\e[1;33m%-10s\e[0m%-60s\n" "dup" "$2" ""
  else
    print_fullname "$1" "$2"
#    rsync -aq --update -e ssh "$2".zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/"$1"/"$2".zip
  fi
}

push_cps3_game() {
  if [ -f ${FBNEOROMDIR}/"$1"n.zip ]; then
    mkdir -p /tmp/"$1"
    cd /tmp/"$1"
    unzip -qo ${FBNEOROMDIR}/"$1".zip
    unzip -qo ${FBNEOROMDIR}/"$1"n.zip
    zip -qo -9 "$1"n.zip *
    push_game fbneo "$1"n
    cd /tmp
    [[ -d /tmp/"$1" ]] && rm -rf /tmp/"$1"
  elif [ -f ${FBNEOROMDIR}/"$1".zip ]; then
    cd ${FBNEOROMDIR}
    push_game fbneo "$1"
  else
    printf "%-10s\e[1;31m%-10s\e[0m%-60s\n" "none" "$1" ""
  fi
}

push_konami_game() {
  print_fullname "$1" "$2"
  case "$2" in
    simpsons)
      ALTROM="simpsn2p.zip"
      ;;
    ssriders)
      ALTROM="ssrdrubc.zip"
      ;;
    tmnt)
      ALTROM="tmht2p.zip"
      ;;
    tmnt2|xmen)
      ALTROM="${2}2p.zip"
      ;;
    esac
    echo rsync -aq --update -e ssh "$2".zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/"$1"/${ALTROM}
}

push_emu() {
  case "$2" in
    kov*|orlegend|pgm|photoy2k|sf2t|quiz*|dmnfrnt|drgw2|dw2001|dwpc|happy6|killbld*|martmast|olds*|puzlstar|puzzli2|svg|sfzch|wofch|theglad|bakatono|froman2b|janshin|mahretsu|marukodq|quiz*|stakwin*)
      ;;
    simpsons|ssriders|tmnt|tmnt2|xmen)
      push_konami_game "$1" "$2"
      ;;
    *)
      push_game "$1" "$2"
      ;;
  esac
}

select_emu() {
  case "$2" in
    cps2.cpp|neogeo.cpp|segas16b.cpp)
      cd ${FBNEOROMDIR}
      push_game fbneo "$1"
      ;;
    cps3.cpp)
      push_cps3_game "$1"
      ;;
    dec0.cpp)
      cd ${MAME2k3ROMDIR}
      push_game mame2003 "$1"
      ;;
    *)
      if [ -f ${MAME2k3ROMDIR}/"$2".zip ]
      then
        cd ${MAME2k3ROMDIR}
        push_emu mame2003 "$2"
      elif [ -f $FBNEOROMDIR/"$2".zip ]
      then
        cd ${FBNEOROMDIR}/
        push_emu fbneo "$2"
      else echo -e "\033[0;31m$2\033[0m not found, skipping..."
      fi
      ;;
  esac
}

if [ $# -lt 1 ]
  then
    usage
fi

while [ $# -ne 0 ]
do
  if is_present "$1"; then
    echo -e "Game \033[0;33m$1\033[0m already present, skipping..."
  else
    DRIVER=$(${MAMEBIN} -listsource $1 | awk '{print $2}')
    echo -e "Driver is \033[0;33m${DRIVER}\033[0m, pushing games..."
    for GAME in $(${MAMEBIN} -listsource | grep -w $(echo ${DRIVER}) | awk '{print $1}')
    do
      if ! is_clone ${GAME}
      then
        select_emu ${GAME} ${DRIVER}
      fi
    done
  fi
  shift
done
