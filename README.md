# attract-tools

These tools are used to manage romsets from a remote host to a Picade.
The gamelist.xml files must be decompressed before running the playlist-manager.

# ffmpeg-pi4.sh

Only useful when downloading videos from Youtube and resizing / cropping them to fit. Initially written for PS1/DC videos.

# fixmp4.sh

Found out some videos were lacking MMAL? This script will re-download and recompress EVERYTHING from Progetto-Snaps. A bit rough but effective. 

# pi3_pushroms.sh

Deprecated, used to push roms on a Raspberry Pi 3 arcade cabinet.

# pi4_lpl.sh

Generates Retroarch playlists for games found on Raspberry Pi 4. Useful with Lakka, not so much with Attract-Mode.

# pi4_pushroms.sh

Uses conf found in `settings` in order to push games. Run with an argument (a game name) and will push every game running on the same hardware, except the games blacklisted in `settings` (adult, mahjong, bootlegs, clones, racing, gun, everything that doesn't fit on a 1-player bartop). Pushes for FBNeo by default, then  MAME2003. Also pushes for regular MAME in the case of Model1/2 but the Pi 4 is still too slow for these.

# playlist_manager.py

Lists all roms present on the Pi4 and generates Attract-Mode playlists using metadata found in XML files. Pushes the Playlist to Pi4 when done.

# settings

Sets a few PATHs and the blacklisted game names, mandatory file

# video-dl.sh

A more subtle version of a video file downloader, does case-per-case downloading and converting, has the ability to crop time.
