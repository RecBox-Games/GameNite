#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "usage: gcp-upload <game-name> <directory> [<bucket-name>]"
    echo "- default bucket name is gamenite-games-testing"
    exit 1
fi

game=$1
dir=$2
bucket=${3-gamenite-games-development}

chillin="true"
function check_for {
    if [[  -z "$(ls $1 2>/dev/null)" ]]; then
	    echo "didn't find $1 file"
	    chillin="false"
    fi
}

cd $dir

# check for preview.png, icon.png, description.txt, game/, game/meta.txt, game/controller/
check_for "preview.png" 
check_for "icon.png"
check_for "description.txt"
check_for "game"
check_for "game/meta.txt"
check_for "game/controller"

if [[ "$chillin" == "false" ]]; then
    exit 1
fi

# compress game files into tarball
cd game
echo "taring files in game/"
tar -czf ../game.tar.gz $(ls -a --color=never | grep -v "^\.\.\?$")
cd ..

echo "uploading files"
gsutil mkdir gs://$bucket/$game
gsutil cp ./icon.png gs://$bucket/$game/icon
gsutil cp ./icon.png gs://$bucket/$game/icon.png
gsutil cp ./preview.png gs://$bucket/$game/preview
gsutil cp ./description.txt gs://$bucket/$game/description
gsutil setmeta -h "Cache-Control:no-cache, max-age=10" gs://$bucket/$game/game
gsutil cp ./game.tar.gz gs://$bucket/$game/game

echo done
