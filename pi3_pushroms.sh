#!/bin/bash

. ./settings

SCRIPTPATH=$(pwd)
MAME2k3ROMDIR=$GAMESDIR/mame2003/
FBNEOROMDIR=$GAMESDIR/fbneo/
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
$MAMEBIN -listfull | sort > ${SCRIPTPATH}/LISTFULL

shopt -s extglob
BOOTLEG='+(39in1|aladmdb|backfirt|barek3mb|black|bldyr3b|brod|chry10|cpokerpk|cps3boot|crswd2bl|denseib|empcity|endless|ffight2b|froman2b|fspiderb|gmgalax|igromult|iron|janputer|jparkmb|kbash2|kinstb|kok|lasthope|legendsb|lucky74|m4tupen|mjreach|mk3mdb|mk3snes|moguchan|mstworld|pengadvb|pesadelo|protennb|rushbets|sblast2b|shinfz|slotunbl|smssgame|smssgamea|sonic2mb|srmdb|ssf2mdb|tetrbx|tetriskr|tourvis|twinktmb|venom|zigzagb|zintrckb|bootleg_sys16a_sprite|seibu_cop_boot|neocart_matrimbl|neocart_kof10th|neocart_kof2002b|neocart_kf2k3bl|neocart_boot|neocart_garoubl|neocart_kof97oro|neocart_kf10thep|neocart_kf2k5uni|neocart_kf2k4se|neocart_lans2004|neocart_samsho5b|neocart_mslug3b6|neocart_ms5plus|neocart_kog|neocart_svcboot|neocart_svcplus|neocart_svcplusa|neocart_svcsplus|ng_cthd_prot|ng_kof2k3bl_prot|ngboot_prot|nes_mbaby|nes_asn)'
CONVERSION='+(8ballact|dariusgx|drakton|drivfrcp|fantastc|fastdrwp|kong|lasthope|megadpkr|moonal2|reaktor|spcwarp|superbon|timefgtr|v4dealem|zigzagb)'
KOREA='+(atomicp|hexa|jpopnics|snapper|tetrsark)'
MAHJONG='+(4psimasy|7jigen|akiss|av2mj1bb|av2mj2rg|bakatono|bananadr|cafebrk|cafedoll|cafepara|cafetime|chinmoku|club90s|cmehyou|csplayh1|csplayh5|csplayh6|cultures|daimyojn|daireika|daiyogen|dokyusei|dokyusp|dondenmj|dtoyoken|dunhuang|emjjoshi|emjscanb|emjtrapz|froman2b|fromanc2|fromanc4|fromance|fromancr|gakusai|gakusai2|gal10ren|galkaika|galkoku|gekisha|goodejan|hanamomo|hotgmcki|hourouki|hypreac2|hypreact|idolmj|imekura|janbari|janjans1|janjans2|janputer|janshinp|jantotsu|jituroku|jogakuen|jongbou|jongtei|jyangoku|kaguya|kaguya2|kakumei|kakumei2|kisekaem|kiwame|kiwames|koinomp|korinai|lemnangl|lhzb2|mahjngoh|mahretsu|majrjhdx|majs101b|majxtal7|mcnpshnt|mcontest|mfightc|mfunclub|mgakuen|mgakuen2|mgcs|mgdh|mgmen89|mhgaiden|mhhonban|minasan|mirage|mj1|mj2|mj3|mj3evo|mj3evoup|mj4simai|mjangels|mjcamera|mjcamerb|mjchuuka|mjclinic|mjclub|mjcomv1|mjdchuka|mjdejavu|mjderngr|mjdialq2|mjdiplob|mjegolf|mjelctrn|mjflove|mjfocus|mjfriday|mjgaiden|mjgalpri|mjgnight|mjgottsu|mjgottub|mjgtaste|mjhokite|mjifb|mjikaga|mjjoship|mjkinjas|mjkjidai|mjkoiura|mjkojink|mjlaman|mjlstory|mjmaglmp|mjmania|mjmyorn2|mjmyster|mjmyuniv|mjnanpas|mjnatsu|mjnquest|mjprivat|mjreach|mjreach1|mjschuka|mjsenka|mjsenpu|mjsikaku|mjsister|mjsiyoub|mjtensin|mjuraden|mjvegasa|mjyarou|mjyougo|mjyuugi|mjzoomin|mkeibaou|mladyhtr|mmehyou|mmmbanc|mogitate|momotaro|mrokumei|mscoutm|msjiken|myfairld|neruton|nmsengen|ntopstar|otatidai|otonano|ougonhai|pachiten|patimono|ponchin|pss62|pstadium|ptrmj|qmhayaku|renaiclb|renaimj|rmhaihai|rmhaijin|rmhaisei|ron2|royalmj|ryouran|sailorws|scandal|sdmg2|sengokmj|sengomjk|shabdama|slqz2|slqz3|srmp1|srmp2|srmp3|srmp4|srmp5|srmp6|srmp7|srmvs|sryudens|taiwanmb|telmahjn|tenkai|themj|tjsb|tmmjprd|tonpuu|triplew1|triplew2|uchuuai|ultramhm|urashima|usagiym|vanilla|vitaminc|vmahjong|vsmahjng|wcatcher|yarunara|yosimoto|nb1412m2|nb1413m3|nb1414m4|md_rom_mjlov|md_rom_cjmjclub|neogeo_mj_ac|neogeo_mj|nes_txc_mjblock|nes_mjpanel)'
MATURE='+(bakatono|blockgal|choko|honeydol|marukin|marvins|pairlove|peekaboo|pkladies|prtytime|stoffy|streakng|toffy|wiggie)'
PROTOTYPE='+(3on3dunk|airrace|akkaarrh|androidp|arcadecl|argusg|asylum|b85cb7p|barata|barbball|bbprot|beathead|biofreak|bombsa|bowarrow|boxer|bygone|c264|c65|calcune|catchp|cball|chimerab|clcd|cloud9|commandw|cue|cybstorm|dankuga|demndrgn|diggerma|divebomb|doraemon|dualgame|firebeas|fishfren|flicker|freezeat|galgame4|gemcrush|ghostlop|guts|hamaway|hangzo|hdrivair|insector|inyourfa|ironclad|ixion|j6hisprt|jumpkun|kngtmare|laststar|lemmings|m3scoop|madmotor|marvland|mazeinv|metalmx|mgolf|moonwarp|mtouchxl|nms8260|orbatak|orbs|packbang|pastelis|pc_bload|pc_ttoon|playball|popshot|pprobe|pr_trktp|puzlclub|pzletime|qb3|qwak|recalh|rockduck|rockn4|rotr|rrreveng|runaway|sc1cshat|sc2cexpl|sc2cgc|screwloo|shrike|sparkz|spdball|spdcoin|sqbert|strax_p7|strtdriv|tankbatl|tattass|teetert|tenthdeg|toggle|tomcat|toratora|tshoot|turbosub|turbotag|twinqix|tylz|v4vgpok|vcircle|vdogdeme|vdogdemo|vidvince|warpsped|wingforc|wizwarz|wolfpack|xorworld|np600a3|c64_4cga|aic6250|aic6251a)'
QUIZZES='+(atamanot|atehate|bkrtmaq|cashquiz|coronatn|cworld|cworld2j|danchiq|dquizgo|dquizgo2|fbcrazy|funquiz|funquiza|funquizb|gakupara|gekiretu|gp2quiz|hatena|hayaosi1|hayaosi2|hayaosi3|hotdebut|hyhoo|hyhoo2|inquiztr|introdon|inufuku|kaiunqz|keithlcy|ldquiz4|livequiz|lsrquiz|lsrquiz2|macha|marukodq|mdhorse|mv1cwq|myangel|myangel2|myangel3|nettoqc|qad|qcrayon|qcrayon2|qdrmfgp|qdrmfgp2|qgakumon|qgh|qgundam|qjinsei|qkracer|qmegamis|qmhayaku|qndream|qrouka|qsangoku|qsww|qtheater|qtono1|qtono2j|qtorimon|quaquiz2|quiz|quiz18k|quiz211|quiz365|quizard|quizard2|quizard3|quizard4|quizchq|quizdai2|quizdais|quizdna|quizf1|quizhq|quizhuhu|quizkof|quizmeku|quizmoon|quizmstr|quizo|quizpani|quizpun|quizpun2|quizqgd|quizshow|quiztou|quiztvqq|quizvadr|quizvid|quizwizc|qzchikyu|qzkklgy2|qzkklogy|qzquest|qzshowby|ryorioh|sukuinuf|sunaq|supertr|trivquiz|wizzquiz|xsedae|yesnoj|yuyugogo)'
RACING='+(enduror|f1*|finallap|finalap*|fourtrax|gprider|hangon|hcrash|konamigt|outrun|toutrun|orunners|shangon|slipstrm|smgp)'
REJECTS='+(1943mii|3in1semi|4dwarrio|4in1boot|atomicp|bakutotu|blazer|boxyboy|brain|bwcasino|cannonbp|catacomb|chinatwn|cleopatr|cookbib2|cookbib3|crswd2bl|cupfinal|dakkochn|dangseed|dbzvrvs|deerhunt|dmnfrnt|dokaben|dragonsh|dremshpr|drgnbowl|drgw2|dw2001|dwpc|eggor|euroch92|f1*|faceoff|fantastc|finallap|finalap*|finalttr|finehour|gardia|godzilla|gunlock|hal21|happy6|hvymetal|hwrace|hyperpac|imsorry|intcup94|isgsm|ixion|janshin|jdreddp|jitsupro|jockeygp|jpark|jpopnics|killbld*|kirameki|korokoro|koshien|kov*|kyukaidk|landmakr|legend|lightbr|lottofun|luctoday|madshark|majtitle|martmast|mastkin|metlhawk|mmaze|mmonkey|moremore|moremorp|moshougi|mrtnt|neobattl|oisipuzl|olds*|orbitron|ordyne|orlegend|pbobble|pbobble2|penbros|pgm|photoy2k|pisces|pistoldm|prmrsocr|ptblank|puchicar|puzlstar|puzzli2|pwrgoal|pzlbowl|pzlbreak|quester|raflesia|razmataz|rocktrv2|roishtar|rompers|ryujin|ryukyu|sbm|scross|sdtennis|sf2t|sfposeid|sfx|sfzch|shadowld|shinfz|shootgal|sjryuko|skybase|snapper|snowbro3|sokonuke|spacecr|spaceskr|spatter|spcfrcii|spclforc|spdball|spdcoin|srdmissn|stakwin*|supbtime|superbon|suzuk*|svg|sws*|tdpgal|tetrsark|theglad|tokisens|toppyrap|toryumon|toto|trophyh|trstar|tstrike|twinkle|twinqix|ufosensi|umanclub|utoukond|vanvan|vliner|vshoot|waterski|wits|wldcourt|wmatch|wofch|woodpeck|worldwar|ws|wtennis|wwallyj)'

KONAMI='+(simpsons|ssriders|tmnt|tmnt2|xmen)'

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

push_game() {
  if is_present "$2"; then
    print_yellow "dup" "$2" "${FULLNAME}"
  else
    print_green "$1" "$2" "$FULLNAME"
    if [ -f "$2".zip ]; then
      if [ -n "${STAGING+1}" ]; then
        print_yellow "staging" "$2" "not pushing"
      else
        rsync -aq --update -e ssh "$2".zip ${PI3_USER}@${PI3_IP}:${PI3_ROMPATH}/"$1"/"$2".zip
      fi
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
  print_green "$1" "$2" "$FULLNAME"
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
      print_yellow "bootleg" "$2" "${FULLNAME}"
      ;;
    ${CONVERSION})
      print_yellow "convert" "$2" "${FULLNAME}"
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
          print_green "mame2003" "spidman" "${FULLNAME}"
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
    print_yellow "dup" "$1" "game already present, skipping driver"
  else
    DRIVER=$(${MAMEBIN} -listsource $1 | awk '{print $2}' | cut -d '.' -f 1)
    print_blue "Emulator" "Rom" "Driver: ${DRIVER}"
    for GAME in $(${MAMEBIN} -listsource | grep -w $(echo ${DRIVER}.cpp) | awk '{print $1}')
    do
      if ! is_clone ${GAME}
      then
        FULLNAME=$(grep -w "${GAME}" ${SCRIPTPATH}/LISTFULL | cut -d '"' -f 2 | tr '/' '_' | sed 's/\ \~\ /\)\(/')
        select_driver ${GAME} ${DRIVER}
      fi
    done
  fi
  shift
done

rm -f ${SCRIPTPATH}/LISTFULL
exit 0
