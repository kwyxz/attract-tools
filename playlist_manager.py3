#!/usr/bin/env python3

"""
Generate attract-mode playlist based off games found on Pi
"""

import datetime
from os import path
import sys
import paramiko
from lxml import etree

# basic settings relevant to the Pi being used
HOSTNAME = "192.168.0.9"
USER = "kwyxz"
SSHKEY = f"/home/{USER}/.ssh/id_rsa_kwyxz_4096b"
ROMPATH = f"/home/{USER}/roms"
LOCAL_PLAYLIST = "./Picade.txt"
REMOTE_PLAYLIST = f"/home/{USER}/.attract/romlists/Picade.txt"

# databases
MAME_DB = './gamelist078.xml'
FBNEO_DB = './gamelist0229.xml'

# files to ignore if found
biosfiles = ['neogeo','cpzn1','cpzn2','konamigx','skns']

# in case of any error
def die(message):
    """in case of any error"""
    print("\u001b[31mERROR:\u001b[0m " + message)
    sys.exit(1)

# list games on the remote Pi
def listgames(hostname, user, sshkey, rompath):
    """list games on the remote Pi"""
    games = []
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        command = 'cd ' + rompath + r' && find . -type f \( -name "*.zip" -o -name "*.7z" \)'
        (_, stdout, _) = sshcon.exec_command(command)
        for line in stdout.readlines():
            games.append(line.split('\n')[0])
        sshcon.close()
    except paramiko.ssh_exception.NoValidConnectionsError:
        die("Unable to connect to the remote host, check the network parameters")
    return games

# if a playlist is already present on the remote host, download it
def retrievepl(hostname,user,sshkey,remote_playlist,local_playlist):
    """if a playlist is already present on the remote host, download it"""
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        sftp=sshcon.open_sftp()
        sftp.get(remote_playlist,local_playlist)
        print("No local playlist found, remote playlist downloaded")
    except FileNotFoundError:
        print("No local or remote playlist found, creating new one")
    sftp.close()
    sshcon.close()

# upload the playlist that is present on the local host to the remote
def pushpl(hostname,user,sshkey,local,remote):
    """upload the playlist that is present on the local host to the remote"""
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        sftp=sshcon.open_sftp()
        # if a playlist is present on the remote, back it up
        try:
            backupname = remote + "." + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
            sftp.rename(remote,backupname)
            print("Previous remote playlist saved to " + backupname)
        # if no playlist is on the remote, simply print this
        except FileNotFoundError:
            print("No existing remote playlist, uploading new one")
        sftp.put(local,remote,callback=None,confirm=True)
        print("Updated playlist uploaded to remote location")
    except paramiko.ssh_exception.NoValidConnectionsError:
        die("Unable to connect to the remote host, check the network parameters")
    sftp.close()
    sshcon.close()

# this file is used to find the game categories
def category(name):
    """this file is used to find the game categories"""
    with open('catver.ini','r') as catfile:
        catver = catfile.readlines()
    categ = "None"
    for line in catver:
        if name + "=" in line:
            categ = line.split("=")[1].rstrip()
            break
    return categ

# check out if the game is already in the playlist
def is_present(romfile,romlist):
    """check out if the game is already in the playlist"""
    result = False
    with open(romlist,'r') as filelist:
        lines = filelist.readlines()
    for line in lines:
        if line.startswith(romfile + ";"):
            result = True
            break
        if romfile in biosfiles:
            result = True
            break
    return result

def strip_title(absrom):
    """split to return the title"""
    return absrom.split('/')[2].split('.')[0]

def find_emu(absrom):
    """split to return the emu"""
    return absrom.split('/')[1]

# pretty-print the emulator names
def prettyprint(emuname):
    """pretty print the emulator name"""
    if emuname == "fbneo":
        return "Final Burn Neo"
    if emuname == "mame2003":
        return "MAME 2003"
    die("unknown emulator")
    return None

# retrieve the metadata from the XML file
def game_meta(name,xmlroot,node,meta):
    """retrieve game metadata"""
    try:
        xpath = "./" + node + "[@name='" + name + "']/{}"
        return xmlroot.findall(xpath.format(meta))[0].text
    except IndexError:
        die("Either the game %s, its year or manufacturer, were not found in this database" % name)
        return None

def game_meta_misc(name,xmlroot,node,meta,tag):
    """retrieve misc game metadata"""
    try:
        xpath = "./" + node + "[@name='" + name + "']//" + meta
        value = xmlroot.findall(xpath)[0].attrib[tag]
        if value == "vertical":
            return "270"
        if value == "horizontal":
            return "0"
        return value
    except (IndexError,KeyError):
        return ''

# format the name of the manufacturer for better display on Nevato theme cab
def format_string(publisher,length):
    """format the name of the manufacturer for better display on Nevato theme cab"""
    if len(publisher) > length:
        formatted = length-len(publisher)
        publisher = publisher[:formatted] + '-'
    return publisher

# open the XML tree in the metadata files
def open_tree(emulator):
    """open the XML tree in the metadata files"""
    try:
        if emulator == "mame2003":
            tree_mame = etree.parse(MAME_DB)
            return tree_mame
        if emulator == "fbneo":
            tree_fbneo = etree.parse(FBNEO_DB)
            return tree_fbneo
        die("unknown emulator")
        return None
    except FileNotFoundError:
        die("XML files not present")
        return None

# add a line to the playlist
def add_line(gamename,emulator,xmlroot):
    """add a line to the playlist"""
    with open(LOCAL_PLAYLIST,"a") as playlist:
        if emulator == "mame2003":
            nodename = "game"
            print('{:<9} {:<9} \u001b[32m{:<62}\u001b[0m'\
                .format(emulator, gamename,game_meta(gamename,xmlroot,nodename,'description')))
            playlist.write(gamename + ";" \
                + game_meta(gamename,xmlroot,nodename,'description') + ";" \
                + prettyprint(emulator) + ";" + ";" \
                + game_meta(gamename,xmlroot,nodename,'year') + ";" \
                + format_string(game_meta(gamename,xmlroot,nodename,'manufacturer'),9) + ";" \
                + category(gamename) + ";" \
                + game_meta_misc(gamename,xmlroot,nodename,'input','players') + ";" \
                + game_meta_misc(gamename,xmlroot,nodename,'video','orientation') + ";" \
                + game_meta_misc(gamename,xmlroot,nodename,'input','control') + ';' \
                + game_meta_misc(gamename,xmlroot,nodename,'driver','status') + ';1;' \
                + game_meta_misc(gamename,xmlroot,nodename,'video','screen') + ';' \
                + ';' + ';' + ';' \
                + game_meta_misc(gamename,xmlroot,nodename,'input','buttons') + '\n')
        elif emulator == "fbneo":
            nodename = "machine"
            print('{:<9} {:<9} \u001b[32m{:<62}\u001b[0m'\
                .format(emulator, gamename,game_meta(gamename,xmlroot,nodename,'description')))
            playlist.write(gamename + ";" \
                + game_meta(gamename,xmlroot,nodename,'description') + ";" \
                + prettyprint(emulator) + ";" + ";" \
                + game_meta(gamename,xmlroot,nodename,'year') + ";" \
                + format_string(game_meta(gamename,xmlroot,nodename,'manufacturer'),9) + ";" \
                + category(gamename) + ";" \
                + game_meta_misc(gamename,xmlroot,nodename,'input','players') + ";" \
                + game_meta_misc(gamename,xmlroot,nodename,'display','rotate') + ';' \
                + game_meta_misc(gamename,xmlroot,nodename,'control','type') + ';' \
                + game_meta_misc(gamename,xmlroot,nodename,'driver','status') + ';1;' \
                + game_meta_misc(gamename,xmlroot,nodename,'display','type') + ';' \
                + ';' + ';' + ';' \
                + game_meta_misc(gamename,xmlroot,nodename,'control','buttons') + '\n')

# count the amount of games in the playlist
def count_games(fname):
    """count the amount of games in the playlist"""
    i=[]
    with open(fname) as file:
        for i,_ in enumerate(file):
            pass
    return i+1

# main loop
ADDED = 0
roms = listgames(HOSTNAME,USER,SSHKEY,ROMPATH)
LAST_EMU = ''
if path.exists(LOCAL_PLAYLIST):
    print("Local playlist found, updating local playlist")
else:
    retrievepl(HOSTNAME,USER,SSHKEY,REMOTE_PLAYLIST,LOCAL_PLAYLIST)
for rom in roms:
    if not is_present(strip_title(rom),LOCAL_PLAYLIST):
        emu = find_emu(rom)
        game = strip_title(rom)
        if emu != LAST_EMU:
            tree = open_tree(emu)
            treeroot = tree.getroot()
            LAST_EMU = emu
        add_line(game,emu,treeroot)
        ADDED += 1
print("The local playlist is up-to-date")
pushpl(HOSTNAME,USER,SSHKEY,LOCAL_PLAYLIST,REMOTE_PLAYLIST)
print("Total games added : \u001b[32m" + str(ADDED) + "\u001b[0m")
print("Total games in playlist : \u001b[32m" + str(count_games(LOCAL_PLAYLIST)) + "\u001b[0m")

sys.exit(0)
