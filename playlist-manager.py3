#!/usr/bin/env python3

import datetime
import os
from os import path
import paramiko
import lxml
from lxml import etree
# import xml.etree.ElementTree as ET

# basic settings relevant to the Pi being used
hostname = "192.168.1.21"
user = "pi"
sshkey = "/home/kwyxz/.ssh/id_rsa_kwyxz_4096b"
rompath = "/home/pi/roms"
local_playlist = "./Picade.txt"
remote_playlist = "/home/pi/.attract/romlists/Picade.txt"

# databases
MAME_DB = './gamelist078.xml'
FBNEO_DB = './gamelist0223.xml'

# files to ignore if found
biosfiles = ['neogeo','cpzn1','cpzn2']

# in case of any error
def die(message):
    print("\u001b[31mERROR:\u001b[0m " + message)
    exit(1)

# list games on the remote Pi
def listgames(hostname,user,sshkey,path):
    games = []
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        command = 'cd ' + path + ' && find . -type f \( -name "*.zip" -o -name "*.7z" \)'
        (stdin, stdout, stderr) = sshcon.exec_command(command)
        for line in stdout.readlines():
            games.append(line.split('\n')[0])
        sshcon.close()
        return games
    except paramiko.ssh_exception.NoValidConnectionsError:
        die("Unable to connect to the remote host, check the network parameters")

# if a playlist is already present on the remote host, download it
def retrievepl(hostname,user,sshkey,path):
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
    with open('catver.ini','r') as f:
        catver = f.readlines()
    categ = "None"
    for line in catver:
        if name + "=" in line:
            categ = line.split("=")[1].rstrip()
            break
    return categ

# check out if the game is already in the playlist
def is_present(rom,romlist):
    result = False
    with open(romlist,'r') as f:
        lines = f.readlines()
    for line in lines:
        if line.startswith(rom + ";"):
            result = True
            break
        elif rom in biosfiles:
            result = True
            break
    return result

def strip_title(absrom):
    return absrom.split('/')[2].split('.')[0]

def find_emu(absrom):
    return absrom.split('/')[1]

# pretty-print the emulator names
def prettyprint(emuname):
    if emuname == "fbneo":
        return "Final Burn Neo"
    elif emuname == "mame2003":
        return "MAME 2003"
    else:
        die("unknown emulator")

# retrieve the metadata from the XML file
def game_meta(name,root,node,meta):
    try:
        xpath = "./" + node + "[@name='" + name + "']/{}"
        return root.findall(xpath.format(meta))[0].text
    except IndexError:
        die("Either the game %s, its year or manufacturer, were not found in this database" % name)

def game_meta_misc(name,root,node,meta,tag):
    try:
        xpath = "./" + node + "[@name='" + name + "']//" + meta
        value = root.findall(xpath)[0].attrib[tag]
        if value == "vertical":
            return "270"
        elif value == "horizontal":
            return "0"
        return value
    except IndexError:
        return ''
    except KeyError:
        return ''

# format the name of the manufacturer for better display on Nevato theme cab
def format_string(publisher,length):
    if len(publisher) > length:
        formatted = length-len(publisher)
        publisher = publisher[:formatted] + '-'
    return publisher

# open the XML tree in the metadata files
def open_tree(emu):
    try:
        if emu == "mame2003":
            tree_mame = etree.parse(MAME_DB)
            return tree_mame
        elif emu == "fbneo":
             tree_fbneo = etree.parse(FBNEO_DB)
             return tree_fbneo
        die("unknown emulator")
    except FileNotFoundError:
        die("XML files not present")

# add a line to the playlist
def add_line(gamename,emulator,xmlroot):
    with open(local_playlist,"a") as playlist:
        if emulator == "mame2003":
            nodename = "game"
            print('{:<9} {:<9} \u001b[32m{:<62}\u001b[0m'.format(emulator, gamename,game_meta(gamename,xmlroot,nodename,'description')))
            playlist.write(gamename + ";" + game_meta(gamename,xmlroot,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,xmlroot,nodename,'year') + ";" + format_string(game_meta(gamename,xmlroot,nodename,'manufacturer'),9) + ";" + category(gamename) + ";" + game_meta_misc(gamename,xmlroot,nodename,'input','players') + ";" + game_meta_misc(gamename,xmlroot,nodename,'video','orientation') + ";" + game_meta_misc(gamename,xmlroot,nodename,'input','control') + ';' + game_meta_misc(gamename,xmlroot,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,xmlroot,nodename,'video','screen') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,xmlroot,nodename,'input','buttons') + '\n')
        elif emulator == "fbneo":
            nodename = "machine"
            print('{:<9} {:<9} \u001b[32m{:<62}\u001b[0m'.format(emulator, gamename,game_meta(gamename,xmlroot,nodename,'description')))
            playlist.write(gamename + ";" + game_meta(gamename,xmlroot,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,xmlroot,nodename,'year') + ";" + format_string(game_meta(gamename,xmlroot,nodename,'manufacturer'),9) + ";" + category(gamename) + ";" + game_meta_misc(gamename,xmlroot,nodename,'input','players') + ";" + game_meta_misc(gamename,xmlroot,nodename,'display','rotate') + ';' + game_meta_misc(gamename,xmlroot,nodename,'control','type') + ';' + game_meta_misc(gamename,xmlroot,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,xmlroot,nodename,'display','type') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,xmlroot,nodename,'control','buttons') + '\n')

# count the amount of games in the playlist
def count_games(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

# main loop
added = 0
roms = listgames(hostname,user,sshkey,rompath)
last_emu = ''
if path.exists(local_playlist):
    print("Local playlist found, updating local playlist")
else:
    retrievepl(hostname,user,sshkey,remote_playlist)
for rom in roms:
    if not is_present(strip_title(rom),local_playlist):
        emu = find_emu(rom)
        game = strip_title(rom)
        if emu != last_emu:
            tree = open_tree(emu)
            root = tree.getroot()
            last_emu = emu
        add_line(game,emu,root)
        added += 1
print("The local playlist is up-to-date")
pushpl(hostname,user,sshkey,local_playlist,remote_playlist)
print("Total games added : \u001b[32m" + str(added) + "\u001b[0m")
print("Total games in playlist : \u001b[32m" + str(count_games(local_playlist)) + "\u001b[0m")

exit(0)
