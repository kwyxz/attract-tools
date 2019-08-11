#!/usr/bin/env python3

import paramiko
import re
import xml.etree.ElementTree as ET

hostname = "192.168.1.15"
user = "pi"
sshkey = "/home/kwyxz/.ssh/id_rsa_kwyxz_4096b"
path = "/home/pi/RetroPie/roms"
playlist = "./Picade.txt"

def die(message):
    print("ERROR: " + message)
    exit(1)

def listgames(hostname,user,sshkey,path):
    games = []
    sshcon = paramiko.SSHClient()
    sshcon.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    sshcon.connect(hostname, username=user, key_filename=sshkey)
    command = 'cd ' + path + ' && find . -name "*.zip"'
    (stdin, stdout, stderr) = sshcon.exec_command(command)
    for line in stdout.readlines():
        games.append(line.split('\n')[0])
    sshcon.close()
    return games

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
        playlist = f.readlines()
    for line in playlist:
        if rom + ";" in line:
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
        print("the game %s does not exist in this database" % name)

def game_meta_misc(name,root,node,meta,tag):
    try:
        xpath = "./" + node + "[@name='" + name + "']//" + meta
        value = root.findall(xpath)[0].attrib[tag]
        if value == "vertical":
            return "270"
        elif value == "horizontal":
            return "0"
        return value
    except KeyError:
        return ''

def open_tree(emu):
    if emu == "mame2003":
        return ET.parse('gamelist078.xml')
    elif emu == "fba":
        return ET.parse('gamelist0175.xml')
    die("unknown emulator")

def add_line(filename):
    emulator = find_emu(filename)
    gamename = strip_title(filename)

    tree = open_tree(emulator)
    root = tree.getroot()

    if emulator == "mame2003":
        nodename = "game"
        #Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
        print(gamename + ";" + game_meta(gamename,root,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,root,nodename,'year') + ";" + game_meta(gamename,root,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,root,nodename,'input','players') + ";" + game_meta_misc(gamename,root,nodename,'video','orientation') + ";" + game_meta_misc(gamename,root,nodename,'input','control') + ';' + game_meta_misc(gamename,root,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,root,nodename,'video','screen') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,root,nodename,'input','buttons'))
    elif emulator == "fba":
        nodename = "machine"
        #Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
        print(gamename + ";" + game_meta(gamename,root,nodename,'description') + ";" + prettyprint(emulator) + ";" + ";" + game_meta(gamename,root,nodename,'year') + ";" + game_meta(gamename,root,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,root,nodename,'input','players') + ";" + game_meta_misc(gamename,root,nodename,'display','rotate') + ';' + game_meta_misc(gamename,root,nodename,'control','type') + ';' + game_meta_misc(gamename,root,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,root,nodename,'display','type') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,root,nodename,'control','buttons'))
    else:
        die("unknown emulator")

# main loop

roms = listgames(hostname,user,sshkey,path)

for rom in roms:
    if not is_present(strip_title(rom),playlist):
        add_line(rom)

exit(0)
