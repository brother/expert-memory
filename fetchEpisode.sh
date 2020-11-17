#!/bin/bash

#tmp=$(mktemp -d -t download.XXXXXX)
#cleanup() {
#	rm -f "$tmp"
#}
#trap "cleanup" EXI

youtube-dl --extract-audio --audio-format mp3 --write-description "$1"

last=$(find ./episodedata/*.item -type f | tail -n1)
filename=${last##*/}
episode=${filename%*.item}
season=${episode%e*}
number=${episode#*e}
if [[ $number == 0* ]]; then
	number=${number:1:1}
fi
number=$((number+1))

newEpisodeTag="${season}e$number"
if (( number < 10 )); then
	newEpisodeTag="${season}e0$number"
fi

desc=$(find -- *.description)
mp3=$(find -- *.mp3)

mp3File="mp3/$newEpisodeTag.mp3"
mv "$mp3" "$mp3File"

itemFile="episodedata/$newEpisodeTag.item"
mv "$desc" "$itemFile"

echo "" >> "$itemFile"
cat episodedata/template.template >> "$itemFile"

if [[ $itemFile != episodedata/s*e*.item ]]; then
	echo "item file must be on the form s01e02.item"
	exit 1
fi

if ! [[ -f $itemFile ]]; then
	echo "$itemFile does not exists?"
	exit 2
fi

if ! [[ -f $mp3File ]]; then
	echo "Missing mp3 file."
	exit 3
fi

meta=$(./fetchmeta.py "$mp3File")
size=${meta%%;*}
length=${meta##*;}
sed -i "s/EPISODESIZE/$size/g" "$itemFile"
sed -i "s/EPISODELENGTH/$length/g" "$itemFile"
sed -i "s/SEASON/${season:2}/g" "$itemFile"
sed -i "s/EPISODENMBR/$number/g" "$itemFile"
sed -i "s/EPISODETAG/$newEpisodeTag/g" "$itemFile"
sed -i "s/EPISODETITLE/$desc/g" "$itemFile"

echo
echo "Make sure to set the correct pubDate."
echo "Example:"
echo -n "    "
LANG=C date +"%a, %d %b %Y 20:22:00 %Z"
echo
echo "Now edit the item file: $itemFile and update the feed."

git add "$itemFile" "$mp3File"
