#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET

gamename = str(sys.argv[1])
emulator = str(sys.argv[2])

tree = ET.parse('gamelist078.xml')
root = tree.getroot()

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
    xpath = "./game[@name='" + name + "']/{}"
    return root.findall(xpath.format(meta))[0].text

def game_meta_input(name,meta):
    xpath = "./game[@name='" + name + "']/input"
    return root.findall(xpath)[0].attrib[meta]

#Name;Title;Emulator;CloneOf;Year;Manufacturer;Category;Players;Rotation;Control;Status;DisplayCount;DisplayType;AltRomname;AltTitle;Extra;Buttons
print(gamename + ";" + game_meta(gamename,'description') + ";" + emulator + ";;" + game_meta(gamename,'year') + ";" + game_meta(gamename,'manufacturer') + ";" + category(gamename) + ";" + game_meta_input(gamename,'players'))
