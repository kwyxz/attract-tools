#!/bin/bash

. ./settings

MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBNEOROMDIR=$GAMESDIR/fbneo/
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)

shopt -s extglob
QUIZZES='+(atamanot|bkrtmaq|coronatn|cworld2j|danchiq|fbcrazy|gakupara|gekiretu|hatena|hayaosi1|hayaosi2|hayaosi3|hotdebut|hyhoo|hyhoo2|introdon|inufuku|kaiunqz|keithlcy|macha|marukodq|mdhorse|mv1cwq|myangel|myangel2|myangel3|nettoqc|qad|qcrayon|qcrayon2|qdrmfgp|qdrmfgp2|qgakumon|qgh|qgundam|qjinsei|qkracer|qmegamis|qmhayaku|qndream|qrouka|qsangoku|qsww|qtheater|qtono1|qtono2j|qtorimon|*quiz*|qz*|ryorioh|sukuinuf|sunaq|supertr|trivquiz|wizzquiz|xsedae|yuyugogo)'
MAHJONG='+(4psimasy|7jigen|akiss|av2mj1bb|av2mj2rg|bakatono|bananadr|chinmoku|club90s|cmehyou|csplayh1|csplayh5|csplayh6|cultures|daimyojn|daiyogen|dakkochn|dokyusei|dokyusp|dtoyoken|dunhuang|emjjoshi|emjscanb|emjtrapz|froman2b|fromanc2|fromanc4|fromance|fromancr|gakusai|gakusai2|gal10ren|galkaika|galkoku|gekisha|goodejan|hanamomo|hotgmcki|hourouki|hypreac2|hypreact|idolmj|imekura|janbari|janjans1|janjans2|janshin|jantotsu|jituroku|jogakuen|jongbou|jongtei|kaguya|kaguya2|kisekaem|kiwame|kiwames|koinomp|korinai|lemnangl|lhzb2|mahjngoh|mahretsu|majrjhdx|majxtal7|marukin|mcnpshnt|mcontest|md_rom_cjmjclub|md_rom_mjlov|mfightc|mfunclub|mgakuen|mgakuen2|mgcs|mgdh|mgmen89|mhgaiden|mhhonban|mirage|mj1|mj2|mj3|mj3evo|mj3evoup|mj4simai|mjangels|mjcamera|mjcamerb|mjchuuka|mjclinic|mjcomv1|mjdchuka|mjdialq2|mjegolf|mjelctrn|mjflove|mjfocus|mjfriday|mjgaiden|mjgalpri|mjgnight|mjgottsu|mjgottub|mjgtaste|mjhokite|mjikaga|mjjoship|mjkinjas|mjkjidai|mjkoiura|mjkojink|mjlaman|mjlstory|mjmaglmp|mjmania|mjmyorn2|mjmyster|mjmyuniv|mjnanpas|mjnatsu|mjnquest|mjprivat|mjreach|mjreach1|mjschuka|mjsenpu|mjsikaku|mjsister|mjuraden|mjyougo|mjyuugi|mkeibaou|mladyhtr|mmehyou|mmmbanc|mogitate|momotaro|mrokumei|mscoutm|msjiken|myfairld|nb1412m2|nb1413m3|nb1414m4|neruton|nes_mjpanel|nes_txc_mjblock|nmsengen|ntopstar|otatidai|otonano|ougonhai|pachiten|patimono|ponchin|pss62|pstadium|ptrmj|qmhayaku|renaiclb|renaimj|rmhaihai|rmhaijin|rmhaisei|ron2|ryouran|ryukyu|sailorws|scandal|sdmg2|sengokmj|sengomjk|shabdama|sjryuko|slqz2|slqz3|srmp1|srmp2|srmp3|srmp4|srmp5|srmp6|srmp7|srmvs|sryudens|taiwanmb|telmahjn|tenkai|tjsb|tmmjprd|tonpuu|triplew1|triplew2|uchuuai|ultramhm|usagiym|vanilla|vitaminc|vmahjong|vsmahjng|wcatcher|yarunara|yosimoto)'
MATURE='+(bakatono|blockgal|choko|honeydol|pairlove|peekaboo|pkladies|prtytime|stoffy|streakng|toffy|wiggie)'
REJECTS='+(1943mii|3in1semi|4in1boot|dokaben|dmnfrnt|dragonsh|drgw2|dw2001|dwpc|happy6|isgsm|ixion|janshin|jockeygp|killbld*|korokoro|kov*|legend|luctoday|martmast|mastkin|moremorp|olds*|orbitron|orlegend|pbobble|pbobble2|pgm|pisces|photoy2k|puzlstar|puzzli2|rocktrv2|sbm|sf2t|sfzch|shinfz|spcfrcii|spclforc|spdball|spdcoin|stakwin*|superbon|suzuk*|svg|sws*|theglad|tokisens|tstrike|twinqix|wofch)'

KONAMI='+(simpsons|ssriders|tmnt|tmnt2|xmen)'

print_color() {
  printf "%-10.9s\e[1;${4}m%-10.9s\e[0m%-60s\n" "$1" "$2" "$3"
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

usage() {
  printf "Usage: $0 <MAME gamename>"
  exit 1
}

die() {
  printf "ERROR: $1"
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
  print_green "$1" "$2" "$FULLNAME"
}

push_game() {
  if is_present "$2"; then
    print_yellow "dup" "$2" "skipping..."
  else
    print_fullname "$1" "$2"
    if [ -f "$2".zip ]; then
      rsync -aq --update -e ssh "$2".zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/"$1"/"$2".zip
    else
      print_red "critical" "$2" "not found"
    fi
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
    print_red "not MAME" "$1" "skipping..."
  fi
}

push_alt_game() {
  print_fullname "$1" "$2"
  case "$2" in
    simpsons)
      ALTROM="simpsn2p"
      ;;
    ssriders)
      ALTROM="ssrdrubc"
      ;;
    tmnt)
      ALTROM="tmht2p"
      ;;
    tmnt2|xmen)
      ALTROM="${2}2p"
      ;;
    esac
    rsync -aq --update -e ssh "$2".zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/"$1"/${ALTROM}.zip
}

push_emu() {
  case "$2" in
    ${KONAMI})
      push_alt_game "$1" "$2"
      ;;
    ${MAHJONG})
      print_yellow "mahjong" "$2" "skipping..."
      ;;
    ${MATURE})
      print_yellow "mature" "$2" "skipping..."
      ;;
    ${QUIZZES})
      print_yellow "quiz" "$2" "skipping..."
      ;;
    ${REJECTS})
      print_yellow "blacklist" "$2" "skipping..."
      ;;
    *)
      push_game "$1" "$2"
      ;;
  esac
}

select_emu() {
  if [ -f ${MAME2k3ROMDIR}/"$1".zip ]
  then
    cd ${MAME2k3ROMDIR}
    push_emu mame2003 "$1"
  elif [ -f $FBNEOROMDIR/"$1".zip ]
  then
    cd ${FBNEOROMDIR}/
    push_emu fbneo "$1"
  else print_red "notfound" "$1" "skipping..."
  fi
}

select_driver() {
  case "$2" in
    cps2|neogeo|segas16b)
      cd ${FBNEOROMDIR}
      push_emu fbneo "$1"
      ;;
    cps3)
      push_cps3_game "$1"
      ;;
    dec0)
      cd ${MAME2k3ROMDIR}
      push_emu mame2003 "$1"
      ;;
    segas32)
      case "$1" in
        spidman)
          print_fullname "mame2003" "spidman"
          rsync -aq --update -e ssh spidey.zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/mame2003/spidey.zip
          ;;
        *)
          select_emu "$1"
          ;;
      esac
      ;;
    namcos11|stv|jalmah|mahjong|royalmah)
      print_red "denied" "$1" "driver not allowed"
      ;;
    *)
    select_emu "$1"
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
    print_yellow "dup" "$1" "skipping..."
  else
    DRIVER=$(${MAMEBIN} -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    print_blue "Driver is" "${DRIVER}" "pushing games..."
    for GAME in $(${MAMEBIN} -listsource | grep -w $(echo ${DRIVER}.cpp) | awk '{print $1}')
    do
      if ! is_clone ${GAME}
      then
        select_driver ${GAME} ${DRIVER}
      fi
    done
  fi
  shift
done
