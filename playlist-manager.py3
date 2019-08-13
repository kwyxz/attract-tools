#!/usr/bin/env python3

import datetime
import os
from os import path
import paramiko
import xml.etree.ElementTree as ET

hostname = "192.168.1.15"
user = "pi"
sshkey = "/home/kwyxz/.ssh/id_rsa_kwyxz_4096b"
rompath = "/home/pi/RetroPie/roms"
local_playlist = "./Picade.txt"
remote_playlist = "/home/pi/.attract/romlists/Picade.txt"

biosfiles = ['neogeo','cpzn1','cpzn2']

def die(message):
    print("\u001b[31mERROR:\u001b[0m " + message)
    exit(1)

def listgames(hostname,user,sshkey,path):
    games = []
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        command = 'cd ' + path + ' && find . -name "*.zip"'
        (stdin, stdout, stderr) = sshcon.exec_command(command)
        for line in stdout.readlines():
            games.append(line.split('\n')[0])
        sshcon.close()
        return games
    except paramiko.ssh_exception.NoValidConnectionsError:
        die("Unable to connect to the remote host, check the network parameters")

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

def pushpl(hostname,user,sshkey,local,remote):
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        sshcon.connect(hostname, username=user, key_filename=sshkey)
        sftp=sshcon.open_sftp()
        try:
            backupname = remote + "." + datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
            sftp.rename(remote,backupname)
            print("Previous remote playlist saved to " + backupname)
        except FileNotFoundError:
            print("No existing remote playlist, uploading new one")
        sftp.put(local,remote,callback=None,confirm=True)
        print("Updated playlist uploaded to remote location")
    except paramiko.ssh_exception.NoValidConnectionsError:
        die("Unable to connect to the remote host, check the network parameters")
    sftp.close()
    sshcon.close()

def category(name):
    with open('catver.ini','r') as f:
        catver = f.readlines()
    categ = "None"
    for line in catver:
        if name + "=" in line:
            categ = line.split("=")[1].rstrip()
            break
    return categ

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

def prettyprint(emuname):
    if emuname == "fba":
        return "Final Burn Neo"
    elif emuname == "mame2003":
        return "MAME 2003"
    else:
        die("unknown emulator")

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

def open_tree(emu):
    try:
        if emu == "mame2003":
            return ET.parse('gamelist078.xml')
        elif emu == "fba":
            return ET.parse('gamelist0175.xml')
        die("unknown emulator")
    except FileNotFoundError:
        die("XML files not present")

def add_line(filename):
    emulator = find_emu(filename)
    gamename = strip_title(filename)
    tree = open_tree(emulator)
    root = tree.getroot()
    with open(local_playlist,"a") as playlist:
        if emulator == "mame2003":
            nodename = "game"
            print("Adding game \u001b[32m" + game_meta(gamename,root,nodename,'description') + "\u001b[0m to emulator \u001b[33m" + prettyprint(emulator) + "\u001b[0m")
            playlist.write(gamename + ";" + game_meta(gamename,root,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,root,nodename,'year') + ";" + game_meta(gamename,root,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,root,nodename,'input','players') + ";" + game_meta_misc(gamename,root,nodename,'video','orientation') + ";" + game_meta_misc(gamename,root,nodename,'input','control') + ';' + game_meta_misc(gamename,root,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,root,nodename,'video','screen') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,root,nodename,'input','buttons') + '\n')
        elif emulator == "fba":
            nodename = "machine"
            print("Adding game \u001b[32m" + game_meta(gamename,root,nodename,'description') + "\u001b[0m to emulator \u001b[33m" + prettyprint(emulator) + "\u001b[0m")
            playlist.write(gamename + ";" + game_meta(gamename,root,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,root,nodename,'year') + ";" + game_meta(gamename,root,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,root,nodename,'input','players') + ";" + game_meta_misc(gamename,root,nodename,'display','rotate') + ';' + game_meta_misc(gamename,root,nodename,'control','type') + ';' + game_meta_misc(gamename,root,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,root,nodename,'display','type') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,root,nodename,'control','buttons') + '\n')

def count_games(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

# main loop
added = 0
roms = listgames(hostname,user,sshkey,rompath)
if path.exists(local_playlist):
    print("Local playlist found, updating local playlist")
else:
    retrievepl(hostname,user,sshkey,remote_playlist)
for rom in roms:
    if not is_present(strip_title(rom),local_playlist):
        add_line(rom)
        added += 1
print("The local playlist is up-to-date")
if added > 0:
    pushpl(hostname,user,sshkey,local_playlist,remote_playlist)
    print("Total games added : \u001b[32m" + str(added) + "\u001b[0m")
else:
    print("No games added : remote file left untouched")
print("Total games in playlist : \u001b[32m" + str(count_games(local_playlist)) + "\u001b[0m")

exit(0)
