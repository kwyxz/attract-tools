#!/bin/bash

. ./settings

# a few things to set beforehand
SCRIPTPATH=$(pwd)
# the location of the MAME 2003 fullset on the local host
MAME2k3ROMDIR=$GAMESDIR/mame2003/
# the location of the Final Burn Neo fullset on the local host
FBNEOROMDIR=$GAMESDIR/fbneo/
# the command that will be run ton establish what games are clones
CLONES=$($MAMEBIN -listclones | awk '{print $1}' | sort | uniq)
# the complete list of games, it saves time and RAM to just create a flat file
$MAMEBIN -listfull | sort > ${SCRIPTPATH}/LISTFULL

# here are the "blacklists", games that we do not want to push
shopt -s extglob
# Bootlegs
BOOTLEG='+(39in1|aladmdb|backfirt|barek3mb|black|bldyr3b|brod|chry10|cpokerpk|cps3boot|crswd2bl|denseib|empcity|endless|ffight2b|froman2b|fspiderb|gmgalax|igromult|iron|janputer|jparkmb|kbash2|kinstb|kok|lasthope|legendsb|lucky74|m4tupen|mjreach|mk3mdb|mk3snes|moguchan|mstworld|pengadvb|pesadelo|protennb|rushbets|sblast2b|shinfz|slotunbl|smssgame|smssgamea|sonic2mb|srmdb|ssf2mdb|tetrbx|tetriskr|tourvis|twinktmb|venom|zigzagb|zintrckb|bootleg_sys16a_sprite|seibu_cop_boot|neocart_matrimbl|neocart_kof10th|neocart_kof2002b|neocart_kf2k3bl|neocart_boot|neocart_garoubl|neocart_kof97oro|neocart_kf10thep|neocart_kf2k5uni|neocart_kf2k4se|neocart_lans2004|neocart_samsho5b|neocart_mslug3b6|neocart_ms5plus|neocart_kog|neocart_svcboot|neocart_svcplus|neocart_svcplusa|neocart_svcsplus|ng_cthd_prot|ng_kof2k3bl_prot|ngboot_prot|nes_mbaby|nes_asn)'
# Conversions (some of them are good games though)
CONVERSION='+(8ballact|dariusgx|drakton|drivfrcp|fantastc|fastdrwp|kong|lasthope|megadpkr|moonal2|reaktor|spcwarp|superbon|timefgtr|v4dealem|zigzagb)'
# Korean bootlegs
KOREA='+(atomicp|hexa|jpopnics|snapper|tetrsark)'
# Mah-jong games
MAHJONG='+(4psimasy|7jigen|akiss|av2mj1bb|av2mj2rg|bakatono|bananadr|cafebrk|cafedoll|cafepara|cafetime|chinmoku|club90s|cmehyou|csplayh1|csplayh5|csplayh6|cultures|daimyojn|daireika|daiyogen|dokyusei|dokyusp|dondenmj|dtoyoken|dunhuang|emjjoshi|emjscanb|emjtrapz|froman2b|fromanc2|fromanc4|fromance|fromancr|gakusai|gakusai2|gal10ren|galkaika|galkoku|gekisha|goodejan|hanamomo|hotgmcki|hourouki|hypreac2|hypreact|idolmj|imekura|janbari|janjans1|janjans2|janputer|janshinp|jantotsu|jituroku|jogakuen|jongbou|jongtei|jyangoku|kaguya|kaguya2|kakumei|kakumei2|kisekaem|kiwame|kiwames|koinomp|korinai|lemnangl|lhzb2|mahjngoh|mahretsu|majrjhdx|majs101b|majxtal7|mcnpshnt|mcontest|mfightc|mfunclub|mgakuen|mgakuen2|mgcs|mgdh|mgmen89|mhgaiden|mhhonban|minasan|mirage|mj1|mj2|mj3|mj3evo|mj3evoup|mj4simai|mjangels|mjcamera|mjcamerb|mjchuuka|mjclinic|mjclub|mjcomv1|mjdchuka|mjdejavu|mjderngr|mjdialq2|mjdiplob|mjegolf|mjelctrn|mjflove|mjfocus|mjfriday|mjgaiden|mjgalpri|mjgnight|mjgottsu|mjgottub|mjgtaste|mjhokite|mjifb|mjikaga|mjjoship|mjkinjas|mjkjidai|mjkoiura|mjkojink|mjlaman|mjlstory|mjmaglmp|mjmania|mjmyorn2|mjmyster|mjmyuniv|mjnanpas|mjnatsu|mjnquest|mjprivat|mjreach|mjreach1|mjschuka|mjsenka|mjsenpu|mjsikaku|mjsister|mjsiyoub|mjtensin|mjuraden|mjvegasa|mjyarou|mjyougo|mjyuugi|mjzoomin|mkeibaou|mladyhtr|mmehyou|mmmbanc|mogitate|momotaro|mrokumei|mscoutm|msjiken|myfairld|neruton|nmsengen|ntopstar|otatidai|otonano|ougonhai|pachiten|patimono|ponchin|pss62|pstadium|ptrmj|qmhayaku|renaiclb|renaimj|rmhaihai|rmhaijin|rmhaisei|ron2|royalmj|ryouran|sailorws|scandal|sdmg2|sengokmj|sengomjk|shabdama|slqz2|slqz3|srmp1|srmp2|srmp3|srmp4|srmp5|srmp6|srmp7|srmvs|sryudens|taiwanmb|telmahjn|tenkai|themj|tjsb|tmmjprd|tonpuu|triplew1|triplew2|uchuuai|ultramhm|urashima|usagiym|vanilla|vitaminc|vmahjong|vsmahjng|wcatcher|yarunara|yosimoto|nb1412m2|nb1413m3|nb1414m4|md_rom_mjlov|md_rom_cjmjclub|neogeo_mj_ac|neogeo_mj|nes_txc_mjblock|nes_mjpanel)'
# Games with NSFW content
MATURE='+(bakatono|blockgal|choko|honeydol|marukin|marvins|pairlove|peekaboo|pipibibs|pkladies|prtytime|stoffy|streakng|toffy|wiggie)'
# Prototypes
PROTOTYPE='+(3on3dunk|airrace|akkaarrh|androidp|arcadecl|argusg|asylum|b85cb7p|barata|barbball|bbprot|beathead|biofreak|bombsa|bowarrow|boxer|bygone|c264|c65|calcune|catchp|cball|chimerab|clcd|cloud9|commandw|cue|cybstorm|dankuga|demndrgn|diggerma|divebomb|doraemon|dualgame|firebeas|fishfren|flicker|freezeat|galgame4|gemcrush|ghostlop|guts|hamaway|hangzo|hdrivair|insector|inyourfa|ironclad|ixion|j6hisprt|jumpkun|kngtmare|laststar|lemmings|m3scoop|madmotor|marvland|mazeinv|metalmx|mgolf|moonwarp|mtouchxl|nms8260|orbatak|orbs|packbang|pastelis|pc_bload|pc_ttoon|playball|popshot|pprobe|pr_trktp|puzlclub|pzletime|qb3|qwak|recalh|rockduck|rockn4|rotr|rrreveng|runaway|sc1cshat|sc2cexpl|sc2cgc|screwloo|shrike|sparkz|spdball|spdcoin|sqbert|strax_p7|strtdriv|tankbatl|tattass|teetert|tenthdeg|toggle|tomcat|toratora|tshoot|turbosub|turbotag|twinqix|tylz|v4vgpok|vcircle|vdogdeme|vdogdemo|vidvince|warpsped|wingforc|wizwarz|wolfpack|xorworld|np600a3|c64_4cga|aic6250|aic6251a)'
# Quizzes (unless you speak japanese)
QUIZZES='+(atamanot|atehate|bkrtmaq|cashquiz|coronatn|cworld|cworld2j|danchiq|dquizgo|dquizgo2|fbcrazy|funquiz|funquiza|funquizb|gakupara|gekiretu|gp2quiz|hatena|hayaosi1|hayaosi2|hayaosi3|hotdebut|hyhoo|hyhoo2|inquiztr|introdon|inufuku|kaiunqz|keithlcy|ldquiz4|livequiz|lsrquiz|lsrquiz2|macha|marukodq|mdhorse|mv1cwq|myangel|myangel2|myangel3|nettoqc|qad|qcrayon|qcrayon2|qdrmfgp|qdrmfgp2|qgakumon|qgh|qgundam|qjinsei|qkracer|qmegamis|qmhayaku|qndream|qrouka|qsangoku|qsww|qtheater|qtono1|qtono2j|qtorimon|quaquiz2|quiz|quiz18k|quiz211|quiz365|quizard|quizard2|quizard3|quizard4|quizchq|quizdai2|quizdais|quizdna|quizf1|quizhq|quizhuhu|quizkof|quizmeku|quizmoon|quizmstr|quizo|quizpani|quizpun|quizpun2|quizqgd|quizshow|quiztou|quiztvqq|quizvadr|quizvid|quizwizc|qzchikyu|qzkklgy2|qzkklogy|qzquest|qzshowby|ryorioh|sukuinuf|sunaq|supertr|trivquiz|wizzquiz|xsedae|yesnoj|yuyugogo)'
# Racing games that require a wheel
RACING='+(enduror|f1*|finallap|finalap*|fourtrax|gprider|hangon|hcrash|konamigt|outrun|toutrun|orunners|shangon|slipstrm|smgp|swa|vr|wingwar)'
# Blacklisted games because of personal preferences
REJECTS='+(1943mii|3in1semi|4dwarrio|4in1boot|atomicp|bakutotu|blazer|boxyboy|brain|bwcasino|cannonbp|catacomb|chinatwn|cleopatr|cookbib2|cookbib3|crswd2bl|cupfinal|dakkochn|dangseed|dbzvrvs|deerhunt|dmnfrnt|dokaben|dragonsh|dremshpr|drgnbowl|drgw2|dw2001|dwpc|eggor|euroch92|f1*|faceoff|fantastc|finallap|finalap*|finalttr|finehour|gardia|godzilla|gunlock|hal21|happy6|hvymetal|hwrace|hyperpac|imsorry|intcup94|isgsm|ixion|janshin|jdreddp|jitsupro|jockeygp|jpark|jpopnics|killbld*|kirameki|korokoro|koshien|kov*|kyukaidk|landmakr|legend|lightbr|lottofun|luctoday|madshark|martmast|mastkin|metlhawk|mmaze|mmonkey|moremore|moremorp|moshougi|mrtnt|neobattl|oisipuzl|olds*|othldrby|orbitron|ordyne|orlegend|pbobble|pbobble2|penbros|pgm|photoy2k|pisces|pistoldm|prmrsocr|ptblank|puchicar|puzlstar|puzzli2|pwrgoal|pzlbowl|pzlbreak|quester|raflesia|razmataz|rocktrv2|roishtar|rompers|ryujin|ryukyu|sbm|scross|sdtennis|sf2t|sfposeid|sfx|sfzch|shadowld|shinfz|shootgal|sjryuko|skybase|snapper|snowbro3|sokonuke|spacecr|spaceskr|spatter|spcfrcii|spclforc|spdball|spdcoin|srdmissn|stakwin*|supbtime|superbon|suzuk*|svg|sws*|tdpgal|tetrsark|theglad|tokisens|toppyrap|toryumon|toto|trophyh|trstar|tstrike|turkhunt|twinkle|twinqix|ufosensi|umanclub|utoukond|vanvan|vliner|vshoot|waterski|wits|wldcourt|wmatch|wofch|woodpeck|worldwar|ws|wschamp|wtennis|wwallyj)'

# These Konami games are 4player by default with no character select screen
# We are going to use alternate 2player versions with a select screen
KONAMI='+(simpsons|ssriders|tmnt|tmnt2|xmen)'

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
  return $(ssh ${PI4_USER}@${PI4_IP} "test -f ${PI4_ROMPATH}/*/${1}.zip")
}

# Upload a game to the remote host
push_game() {
  if is_present ${2}; then
    # If the game is already on the remote host we just skip it
    print_yellow "dup" "$2" "${FULLNAME}"
  else
    # Otherwise we upload it to the appropriate folder
    print_green "$1" "$2" "$FULLNAME"
    if [ -f ${2}.zip ]; then
      # Unless STAGING=1 is set at runtime, then we're only doing a dry run
      if [ -n "${STAGING+1}" ]; then
        print_yellow "staging" "$2" "not pushing"
      else
        # Push the rom through an SSH tunnel
        rsync -aq --update -e ssh ${2}.zip ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/${1}/${2}.zip
      fi
    else
      # If the rom is not found, display a message but continue
      print_red "critical" "$2" "not found"
    fi
  fi
}

# This is unnecessary as Final Burn Neo skips CD loadings
# push_cps3_game() {
#   # if a NoCD version of the game exists, use it
#   if [ -f ${FBNEOROMDIR}/${1}n.zip ]; then
#     # create a temp folder
#     mkdir -p /tmp/${1}
#     cd /tmp/${1}
#     # merge the parent rom with the NoCD one
#     unzip -qo ${FBNEOROMDIR}/${1}.zip
#     unzip -qo ${FBNEOROMDIR}/${1}n.zip
#     zip -qo -9 ${1}n.zip *
#     # push the resulting zip
#     push_game fbneo ${1}n
#     cd /tmp
#     # delete the temp folder
#     [[ -d /tmp/${1} ]] && rm -rf /tmp/${1}
#   # if there is no NoCD version of the game, push the regular rom
#   elif [ -f ${FBNEOROMDIR}/${1}.zip ]; then
#     cd ${FBNEOROMDIR}
#     push_game fbneo ${1}
#   else
#     # if the game is not available, skip
#     print_red "notfound" "$1" "skipping..."
#   fi
# }

# merge parent game $1 with correct version $2
# maybe this could replace the cps3 function in the future
merge_parent_game() {
  if is_present ${2}; then
    # If the game is already on the remote host we just skip it
    print_yellow "dup" "$2" "${FULLNAME}"
  else
    # not necessary for now since all games are MAME2003, but present in case
    if [ -f ${MAME2k3ROMDIR}/${1}.zip ]; then
      EMUROMDIR="mame2003"
    elif [ -f ${FBNEOROMDIR}/${1}.zip ]; then
      EMUROMDIR="fbneo"
    else
      die "rom files for $1 not found"
    fi
    # create a temp folder
    mkdir -p /tmp/${2}
    cd /tmp/${2}
    # merge the parent rom with the child rom
    echo "Merging $2 into $1"
    unzip -qo ${GAMESDIR}/${EMUROMDIR}/${1}.zip
    unzip -qo ${GAMESDIR}/${EMUROMDIR}/${2}.zip
    zip -qo -9 ${2}.zip *
    # upload the resulting game
    # not using push_game as the alternative name might not be in MAME anymore
    print_green "$EMUROMDIR" "$2" "$FULLNAME"
    rsync -aq --update -e ssh /tmp/${2}/${2}.zip ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/${EMUROMDIR}/${2}.zip
    cd /tmp
    # remove the temp folder
    [[ -d /tmp/${2} ]] && rm -rf /tmp/${2}
  fi
}

# find if we need to push an alternate game
push_alt_game() {
  case "$2" in
    simpsons)
      ALTROM="simpsn2p"
      merge_parent_game ${2} ${ALTROM}
      ;;
    ssriders)
      ALTROM="ssrdrubc"
      merge_parent_game ${2} ${ALTROM}
      ;;
    tmnt)
      ALTROM="tmht2p"
      push_game mame2003 ${ALTROM}
      ;;
    tmnt2)
      ALTROM="${2}2p"
      push_game mame2003 ${ALTROM}
      ;;
    xmen)
      ALTROM="${2}2p"
      push_game mame2003 ${ALTROM}
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

# find out if game will run with MAME 2003 or Final Burn Neo
select_emu() {
  # default emulator is MAME
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

# handle driver-specific cases
select_driver() {
  case "$2" in
    cps[23]|neogeo|segas16b)
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
          rsync -aq --update -e ssh spidey.zip ${PI4_USER}@${PI4_IP}:${PI4_ROMPATH}/mame2003/spidey.zip
          ;;
        *)
          select_emu "$1"
          ;;
      esac
      ;;
    # blacklisted drivers
    # some could be whitelisted for Pi4
    namcos11|stv|jalmah|mahjong|royalmah)
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
