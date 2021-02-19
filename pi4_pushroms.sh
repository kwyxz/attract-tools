#!/bin/bash

. ./settings

# a few things to set beforehand
SCRIPTPATH=$(pwd)
# the extension of the roms
EXT='zip'
# the location of the MAME (current) fullset
MAMEROMDIR=$GAMESDIR/mame/
# the location of the MAME 2003 fullset on the local host
MAME2k3ROMDIR=$GAMESDIR/mame2003/
# the location of the Final Burn Neo fullset on the local host
FBNEOROMDIR=$GAMESDIR/fbneo/
# the command that will be run ton establish what games are clones
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
# the complete list of games, it saves time and RAM to just create a flat file
$MAMEBIN -listfull | sort > ${SCRIPTPATH}/LISTFULL

# Print things in beautiful colors
# This is the generic formatting function
# Colors are defined in specific functions below
print_color() {
  printf "%-10.9s%-10.9s\e[1;${4}m%-60s\e[0m\n" "$1" "$2" "$3"
}

print_red() {
  print_color "$1" "$2" "$3" "31"
}

print_green() {
  print_color "$1" "$2" "$3" "32"
}

print_yellow() {
  print_color "$1" "$2" "$3" "33"
}

print_blue() {
  print_color "$1" "$2" "$3" "34"
}

# The standard usage message when no argument is given
usage() {
  printf "Usage: $0 <MAME gamename>"
  exit 1
}

# Print out an error message when an error is encountered
die() {
  printf "ERROR: $1"
  exit 1
}

# Test if a game is present in the clone list
is_clone() {
  return $(echo ${CLONES} | grep -q -w ${1})
}

# Test if a game is already present on the remote Pi
is_present() {
  return $(ssh ${PI4_USER}@${PI4_IP} "test -f ${PI4_ROMPATH}/*/${1}.${EXT}")
}

# Upload a game to the remote host
push_game() {
  if is_present ${2}; then
    # If the game is already on the remote host we just skip it
    print_yellow "dup" "$2" "${FULLNAME}"
  else
    # Otherwise we upload it to the appropriate folder
    if [ -f ${2}.${EXT} ]; then
      print_green "$1" "$2" "$FULLNAME"
      # Unless STAGING=1 is set at runtime, then we're only doing a dry run
      if [ -n "${STAGING+1}" ]; then
        print_yellow "staging" "$2" "not pushing"
      else
        # Push the rom through an SSH tunnel
        rsync -aq --update -e ssh ${2}.${EXT} ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/${1}/${2}.${EXT}
      fi
    else
      # If the rom is not found, display a message but continue
      print_red "critical" "$2" "not found"
    fi
  fi
}

# merge parent game $1 with correct version $2
# maybe this could replace the cps3 function in the future
merge_parent_game() {
  if is_present ${2}; then
    # If the game is already on the remote host we just skip it
    print_yellow "dup" "$2" "${FULLNAME}"
  else
    # not necessary for now since all games are FBNeo, but present in case
    if [ -f ${FBNEOROMDIR}/${1}.${EXT} ]; then
      EMUROMDIR="fbneo"
    elif [ -f ${MAME2k3ROMDIR}/${1}.${EXT} ]; then
      EMUROMDIR="mame2003"
    else
      die "rom files for $1 not found"
    fi
    # create a temp folder
    mkdir -p /tmp/${2}
    cd /tmp/${2}
    # merge the parent rom with the child rom
    echo "Merging $2 into $1"
    if [ ${EXT} == 'zip' ]; then
      unzip -qo ${GAMESDIR}/${EMUROMDIR}/${1}.${EXT}
      unzip -qo ${GAMESDIR}/${EMUROMDIR}/${2}.${EXT}
      zip -qo -9 ${1}.${EXT} *
    elif [ ${EXT} == '7z' ]; then
      7z x -y ${GAMESDIR}/${EMUROMDIR}/${1}.${EXT} > /dev/null
      7z x -y ${GAMESDIR}/${EMUROMDIR}/${2}.${EXT} > /dev/null
      7z a -y ${1}.${EXT} * > /dev/null
    else
      die "unknown extension"
    fi
    # upload the resulting game
    # not using push_game as the alternative name might not be in MAME anymore
    print_green "$EMUROMDIR" "$2" "$FULLNAME"
    rsync -aq --update -e ssh /tmp/${2}/${1}.${EXT} ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/${EMUROMDIR}/${1}.${EXT}
    cd /tmp
    # remove the temp folder
    [[ -d /tmp/${2} ]] && rm -rf /tmp/${2}
  fi
}

# find if we need to push an alternate game
push_alt_game() {
  case "$2" in
    simpsons)
      ALTROM="simpsons2p"
      merge_parent_game ${2} ${ALTROM}
      ;;
    ssriders)
      ALTROM="ssridersubc"
      merge_parent_game ${2} ${ALTROM}
      ;;
    tmnt)
      ALTROM="tmht2p"
      merge_parent_game ${2} ${ALTROM}
      ;;
    tmnt2)
      ALTROM="tmnt22pu"
      merge_parent_game ${2} ${ALTROM}
      ;;
    xmen)
      ALTROM="xmen2pu"
      merge_parent_game ${2} ${ALTROM}
      ;;
    esac
    # with Konami games we need to merge
    # this might not be necessary with future cases
}

# handle specific cases
push_emu() {
  case "$2" in
    ${KONAMI})
      push_alt_game "$1" "$2"
      ;;
    ${BOOTLEG})
      print_yellow "bootleg" "$2" "${FULLNAME}"
      ;;
    ${CONVERSION})
      print_yellow "convert" "$2" "${FULLNAME}"
      ;;
    ${FISHING})
      print_yellow "fishing" "$2" "${FULLNAME}"
      ;;
    ${GUN})
      print_yellow "lightgun" "$2" "${FULLNAME}"
      ;;
    ${KOREA})
      print_yellow "korea" "$2" "${FULLNAME}"
      ;;
    ${MAHJONG})
      print_yellow "mahjong" "$2" "${FULLNAME}"
      ;;
    ${MATURE})
      print_yellow "mature" "$2" "${FULLNAME}"
      ;;
    ${PURIKURA})
      print_yellow "purikura" "$2" "${FULLNAME}"
      ;;
    ${PROTOTYPE})
      print_yellow "prototype" "$2" "${FULLNAME}"
      ;;
    ${QUIZZES})
      print_yellow "quiz" "$2" "${FULLNAME}"
      ;;
    ${RACING})
      print_yellow "racing" "$2" "${FULLNAME}"
      ;;
    ${REJECTS})
      print_yellow "blacklist" "$2" "${FULLNAME}"
      ;;
    *)
      push_game "$1" "$2"
      ;;
  esac
}

# find out if game will run with MAME 2003 or Final Burn Neo
select_emu() {
  # default emulator is FBNeo
  if [ -f ${FBNEOROMDIR}/"$1".${EXT} ]
  then
    cd ${FBNEOROMDIR}
    push_emu fbneo "$1"
  elif [ -f $MAME2k3ROMDIR/"$1".${EXT} ]
  then
    cd ${MAME2k3ROMDIR}/
    push_emu mame2003 "$1"
  else print_red "notfound" "$1" "skipping..."
  fi
}

# handle driver-specific cases
select_driver() {
  case "$2" in
    model1|model2|stv|segabill)
      cd ${MAMEROMDIR}
      push_emu mame "$1"
      ;;
    cps[23]|neogeo|raiden2|segaxbd|segas16a|segas16b|toaplan2)
      # FBNeo mandatory with Pi 4 but better perfs with less overheating
      cd ${FBNEOROMDIR}
      push_emu fbneo "$1"
      ;;
    # cps3)
    #   # CPS3 games must be handled separately to deal with NoCD roms
    #   push_cps3_game "$1"
    #   ;;
    dec0)
      # issues with Final Burn, forcing MAME here
      cd ${MAME2k3ROMDIR}
      push_emu mame2003 "$1"
      ;;
    segas32)
      case "$1" in
        spidman)
          # a rare case of game renamed between MAME 2003 and modern MAME
          print_green "mame2003" "spidman" "${FULLNAME}"
          rsync -aq --update -e ssh spidey.${EXT} ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/mame2003/spidey.${EXT}
          ;;
        *)
          select_emu "$1"
          ;;
      esac
      ;;
    # blacklisted drivers
    # some could be whitelisted for Pi4
    namcos11|jalmah|mahjong|royalmah)
      print_red "denied" "$1" "driver not allowed"
      ;;
    *)
    select_emu "$1"
    ;;
  esac
}

# test argument presence
if [ $# -lt 1 ]
  then
    usage
fi

# main loop
while [ $# -ne 0 ]
do
  if is_present "$1"; then
    # not pushing again a game already present
    # TODO: make sure this is not redundant with code above
    print_yellow "dup" "$1" "game already present, skipping driver"
  else
    # find which driver this is, using current version of MAME
    # we *really* don't want to parse XML files
    # this should be replaced by a flat file though
    DRIVER=$(${MAMEBIN} -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    print_blue "Emulator" "Rom" "Driver: ${DRIVER}"
    # push games running on the same driver
    # this helps discovering lesser-known games that are probably of interest
    for GAME in $(${MAMEBIN} -listsource | grep -w $(echo ${DRIVER}.cpp) | awk '{print $1}')
    do
      # avoid clones, we only want originals
      if ! is_clone ${GAME}
      then
        # get the game's fullname from MAME
        FULLNAME=$(grep -w "${GAME}" ${SCRIPTPATH}/LISTFULL | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
        select_driver ${GAME} ${DRIVER}
      fi
    done
  fi
  shift
done

rm -f ${SCRIPTPATH}/LISTFULL
exit 0
