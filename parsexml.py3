#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET

gamename = str(sys.argv[1])
emulator = str(sys.argv[2])

def die(message):
    print("ERROR: " + message)
    exit(1)

def category(name):
    with open('catver.ini') as f:
        catver = f.readlines()
    categ = "None"
    for line in catver:
        if name + "=" in line:
            categ = line.split("=")[1].rstrip()
            break
    return categ

def game_meta(name,node,meta):
    try:
        xpath = "./" + node + "[@name='" + name + "']/{}"
        return root.findall(xpath.format(meta))[0].text
    except IndexError:
        die("the game does not exist in this database")

def game_meta_misc(name,node,meta,tag):
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

if emulator == "MAME2003":
    tree = ET.parse('gamelist078.xml')
    root = tree.getroot()
    nodename = "game"
    #Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
    print(gamename + ";" + game_meta(gamename,nodename,'description') + ";" + emulator + ";" + ";" + game_meta(gamename,nodename,'year') + ";" + game_meta(gamename,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,nodename,'input','players') + ";" + game_meta_misc(gamename,nodename,'video','orientation') + ";" + game_meta_misc(gamename,nodename,'input','control') + ';' + game_meta_misc(gamename,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,nodename,'video','screen') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,nodename,'input','buttons'))
elif emulator == "fbneo":
    tree = ET.parse('gamelist0175.xml')
    root = tree.getroot()
    nodename = "machine"
    #Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
    print(gamename + ";" + game_meta(gamename,nodename,'description') + ";" + emulator + ";" + ";" + game_meta(gamename,nodename,'year') + ";" + game_meta(gamename,nodename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,nodename,'input','players') + ";" + game_meta_misc(gamename,nodename,'display','rotate') + ';' + game_meta_misc(gamename,nodename,'control','type') + ';' + game_meta_misc(gamename,nodename,'driver','status') + ';1;' + game_meta_misc(gamename,nodename,'display','type') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,nodename,'control','buttons'))
else:
    die("unknown emulator")

exit(0)
