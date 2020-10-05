#!/usr/bin/python3

import os, sys
from mutagen.mp3 import MP3

mp3filename=sys.argv[1]

statinfo = os.stat(mp3filename)
audio = MP3(mp3filename)

print(str(statinfo.st_size) + ";" + str(audio.info.length))
