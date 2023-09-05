#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "usage: gcp-upload <bucket-name> <game-name> <directory>"
    exit 1
fi

chillin="true"
function check_for {
    if [[  -z "$(ls $1 2>/dev/null)" ]]; then
	echo "didn't find $1 file"
	chillin="false"
    fi
}

cd $3

# check for preview.*, icon.*, description.txt, game/, game/meta.txt, game/controller/
check_for "preview*" 
check_for "icon*"
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
gsutil cp ./icon* gs://$1/$2/icon
gsutil cp ./preview* gs://$1/$2/preview
gsutil cp ./description.txt gs://$1/$2/description
gsutil cp ./game.tar.gz gs://$1/$2/game

echo done
