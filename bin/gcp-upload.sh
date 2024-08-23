# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the rqn repository.
#
# GameNight is a free software: you can redistribute it and/or modify
# them under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# GameNight is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# GameNight. If not, see <https://www.gnu.org/licenses/>.

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

# check for preview.png, icon.png, description.txt, meta.txt, game/, and game/controller/
check_for "preview.png" 
check_for "icon.png"
check_for "description.txt"
check_for "meta.txt"
check_for "game"
check_for "game/controller"

# increment version number
sed -i -E 's/^version=([0-9]+)/echo "version=$((\1+1))"/e' meta.txt

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
gsutil cp ./preview.png gs://$bucket/$game/preview
gsutil cp ./description.txt gs://$bucket/$game/description
gsutil cp ./meta.txt gs://$bucket/$game/meta
gsutil setmeta -h "Cache-Control:no-cache, max-age=10" gs://$bucket/$game/game
gsutil cp ./game.tar.gz gs://$bucket/$game/game

echo done
