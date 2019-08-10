#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET

gamename = str(sys.argv[1])
emulator = str(sys.argv[2])

tree = ET.parse('gamelist078.xml')
root = tree.getroot()

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

def game_meta(name,meta):
    try:
        xpath = "./game[@name='" + name + "']/{}"
        return root.findall(xpath.format(meta))[0].text
    except IndexError:
        die("the game does not exist in this database")

def game_meta_misc(name,meta,tag):
    try:
        xpath = "./game[@name='" + name + "']/" + meta
        return root.findall(xpath)[0].attrib[tag]
    except KeyError:
        return ''

def game_meta_video(name,tag):
    xpath = "./game[@name='" + name + "']/video"
    if root.findall(xpath)[0].attrib[tag] == "vertical":
        return "270"
    else:
        return "0"

#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
print(gamename + ";" + game_meta(gamename,'description') + ";" + emulator + ";" + ";" + game_meta(gamename,'year') + ";" + game_meta(gamename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_misc(gamename,'input','players') + ";" + game_meta_video(gamename,'orientation') + ";" + game_meta_misc(gamename,'input','control') + ';' + game_meta_misc(gamename,'driver','status') + ';1;' + game_meta_misc(gamename,'video','screen') + ';' + ';' + ';' + ';' + game_meta_misc(gamename,'input','buttons'))

exit(0)
