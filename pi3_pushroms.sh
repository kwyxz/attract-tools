#!/bin/bash

. ./settings

MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBNEOROMDIR=$GAMESDIR/fbneo/
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)

shopt -s extglob
BOOTLEG='+(39in1|aladmdb|backfirt|barek3mb|black|bldyr3b|brod|chry10|cpokerpk|cps3boot|crswd2bl|denseib|empcity|endless|ffight2b|froman2b|fspiderb|gmgalax|igromult|iron|janputer|jparkmb|kbash2|kinstb|kok|lasthope|legendsb|lucky74|m4tupen|mjreach|mk3mdb|mk3snes|moguchan|mstworld|pengadvb|pesadelo|protennb|rushbets|sblast2b|shinfz|slotunbl|smssgame|smssgamea|sonic2mb|srmdb|ssf2mdb|tetrbx|tetriskr|tourvis|twinktmb|venom|zigzagb|zintrckb|bootleg_sys16a_sprite|seibu_cop_boot|neocart_matrimbl|neocart_kof10th|neocart_kof2002b|neocart_kf2k3bl|neocart_boot|neocart_garoubl|neocart_kof97oro|neocart_kf10thep|neocart_kf2k5uni|neocart_kf2k4se|neocart_lans2004|neocart_samsho5b|neocart_mslug3b6|neocart_ms5plus|neocart_kog|neocart_svcboot|neocart_svcplus|neocart_svcplusa|neocart_svcsplus|ng_cthd_prot|ng_kof2k3bl_prot|ngboot_prot|nes_mbaby|nes_asn)'
CONVERSION='+(8ballact|drakton|drivfrcp|fantastc|fastdrwp|kong|lasthope|megadpkr|reaktor|spcwarp|superbon|timefgtr|v4dealem|zigzagb)'
MAHJONG='+(4psimasy|7jigen|akiss|av2mj1bb|av2mj2rg|bakatono|bananadr|cafebrk|cafedoll|cafepara|cafetime|chinmoku|club90s|cmehyou|csplayh1|csplayh5|csplayh6|cultures|daimyojn|daireika|daiyogen|dokyusei|dokyusp|dondenmj|dtoyoken|dunhuang|emjjoshi|emjscanb|emjtrapz|froman2b|fromanc2|fromanc4|fromance|fromancr|gakusai|gakusai2|gal10ren|galkaika|galkoku|gekisha|goodejan|hanamomo|hotgmcki|hourouki|hypreac2|hypreact|idolmj|imekura|janbari|janjans1|janjans2|janputer|janshinp|jantotsu|jituroku|jogakuen|jongbou|jongtei|kaguya|kaguya2|kakumei|kakumei2|kisekaem|kiwame|kiwames|koinomp|korinai|lemnangl|lhzb2|mahjngoh|mahretsu|majrjhdx|majs101b|majxtal7|mcnpshnt|mcontest|mfightc|mfunclub|mgakuen|mgakuen2|mgcs|mgdh|mgmen89|mhgaiden|mhhonban|mirage|mj1|mj2|mj3|mj3evo|mj3evoup|mj4simai|mjangels|mjcamera|mjcamerb|mjchuuka|mjclinic|mjclub|mjcomv1|mjdchuka|mjdejavu|mjderngr|mjdialq2|mjdiplob|mjegolf|mjelctrn|mjflove|mjfocus|mjfriday|mjgaiden|mjgalpri|mjgnight|mjgottsu|mjgottub|mjgtaste|mjhokite|mjifb|mjikaga|mjjoship|mjkinjas|mjkjidai|mjkoiura|mjkojink|mjlaman|mjlstory|mjmaglmp|mjmania|mjmyorn2|mjmyster|mjmyuniv|mjnanpas|mjnatsu|mjnquest|mjprivat|mjreach|mjreach1|mjschuka|mjsenka|mjsenpu|mjsikaku|mjsister|mjsiyoub|mjtensin|mjuraden|mjvegasa|mjyarou|mjyougo|mjyuugi|mjzoomin|mkeibaou|mladyhtr|mmehyou|mmmbanc|mogitate|momotaro|mrokumei|mscoutm|msjiken|myfairld|neruton|nmsengen|ntopstar|otatidai|otonano|ougonhai|pachiten|patimono|ponchin|pss62|pstadium|ptrmj|qmhayaku|renaiclb|renaimj|rmhaihai|rmhaijin|rmhaisei|ron2|royalmj|ryouran|sailorws|scandal|sdmg2|sengokmj|sengomjk|shabdama|slqz2|slqz3|srmp1|srmp2|srmp3|srmp4|srmp5|srmp6|srmp7|srmvs|sryudens|taiwanmb|telmahjn|tenkai|themj|tjsb|tmmjprd|tonpuu|triplew1|triplew2|uchuuai|ultramhm|urashima|usagiym|vanilla|vitaminc|vmahjong|vsmahjng|wcatcher|yarunara|yosimoto|nb1412m2|nb1413m3|nb1414m4|md_rom_mjlov|md_rom_cjmjclub|neogeo_mj_ac|neogeo_mj|nes_txc_mjblock|nes_mjpanel)'
MATURE='+(bakatono|blockgal|choko|honeydol|pairlove|peekaboo|pkladies|prtytime|stoffy|streakng|toffy|wiggie)'
PROTOTYPE='+(3on3dunk|airrace|akkaarrh|androidp|arcadecl|argusg|asylum|b85cb7p|barata|barbball|bbprot|beathead|biofreak|bombsa|bowarrow|boxer|bygone|c264|c65|calcune|catchp|cball|chimerab|clcd|cloud9|commandw|cue|cybstorm|dankuga|demndrgn|diggerma|divebomb|doraemon|dualgame|firebeas|fishfren|flicker|freezeat|galgame4|gemcrush|ghostlop|guts|hamaway|hangzo|hdrivair|insector|inyourfa|ironclad|ixion|j6hisprt|jumpkun|kngtmare|laststar|lemmings|m3scoop|madmotor|marvland|mazeinv|metalmx|mgolf|moonwarp|mtouchxl|nms8260|orbatak|orbs|packbang|pastelis|pc_bload|pc_ttoon|playball|popshot|pprobe|pr_trktp|puzlclub|pzletime|qb3|qwak|recalh|rockduck|rockn4|rotr|rrreveng|runaway|sc1cshat|sc2cexpl|sc2cgc|screwloo|shrike|sparkz|spdball|spdcoin|sqbert|strax_p7|strtdriv|tankbatl|tattass|teetert|tenthdeg|toggle|tomcat|toratora|tshoot|turbosub|turbotag|twinqix|tylz|v4vgpok|vcircle|vdogdeme|vdogdemo|vidvince|warpsped|wingforc|wizwarz|wolfpack|xorworld|np600a3|c64_4cga|aic6250|aic6251a)'
QUIZZES='+(atamanot|bkrtmaq|cashquiz|coronatn|cworld2j|danchiq|dquizgo|dquizgo2|fbcrazy|funquiz|funquiza|funquizb|gakupara|gekiretu|gp2quiz|hatena|hayaosi1|hayaosi2|hayaosi3|hotdebut|hyhoo|hyhoo2|inquiztr|introdon|inufuku|kaiunqz|keithlcy|ldquiz4|livequiz|lsrquiz|lsrquiz2|macha|marukodq|mdhorse|mv1cwq|myangel|myangel2|myangel3|nettoqc|qad|qcrayon|qdrmfgp|qdrmfgp2|qgakumon|qgh|qgundam|qjinsei|qkracer|qmegamis|qmhayaku|qndream|qrouka|qsangoku|qsww|qtheater|qtono1|qtono2j|qtorimon|quaquiz2|quiz|quiz18k|quiz211|quiz365|quizard|quizard2|quizard3|quizard4|quizchq|quizdai2|quizdais|quizdna|quizf1|quizhq|quizhuhu|quizkof|quizmeku|quizmoon|quizmstr|quizo|quizpani|quizpun|quizpun2|quizqgd|quizshow|quiztou|quiztvqq|quizvadr|quizvid|quizwizc|qzchikyu|qzkklgy2|qzkklogy|qzquest|qzshowby|ryorioh|sukuinuf|sunaq|supertr|trivquiz|wizzquiz|xsedae|yuyugogo)'
REJECTS='+(1943mii|3in1semi|4in1boot|crswd2bl|dokaben|dmnfrnt|dragonsh|drgnbowl|drgw2|dw2001|dwpc|fantastc|happy6|isgsm|ixion|janshin|jockeygp|killbld*|korokoro|kov*|legend|luctoday|martmast|mastkin|moremorp|olds*|orbitron|orlegend|pbobble|pbobble2|pgm|pisces|photoy2k|puzlstar|puzzli2|rocktrv2|sbm|sf2t|sfzch|shinfz|spcfrcii|spclforc|spdball|spdcoin|stakwin*|superbon|suzuk*|svg|sws*|theglad|tokisens|tstrike|twinqix|wofch)'

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
    ${BOOTLEG})
      print_yellow "bootleg" "$2" "skipping..."
      ;;
    ${CONVERSION})
      print_yellow "convert" "$2" "skipping..."
      ;;
    ${MAHJONG})
      print_yellow "mahjong" "$2" "skipping..."
      ;;
    ${MATURE})
      print_yellow "mature" "$2" "skipping..."
      ;;
    ${PROTOTYPE})
      print_yellow "prototype" "$2" "skipping..."
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
