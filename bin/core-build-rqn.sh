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



set -e

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
dest="$base/rqn/"
flags="$1"

cd $dest
if [[ -n "$(git remote -v | grep westonkelliher)" ]]; then
    echo "------------------------------------------------------------"
    echo "--------------- YOU ARE USING THE WRONG REPO ---------------"
    echo "----------------- delete rqn and try again -----------------"
    echo "------------------------------------------------------------"
fi

if [ ! -z "$(ls $dest)" ]; then
    rm -r $dest/*
fi

cd $base

# Control Pad Server
echo "----- ControlPadSever -----"
cd ControlpadServer
cargo build --release
cp target/release/server $dest/cp_server
cd ..

# Node Web Server
echo "----- WebCP -----"
cd WebCP
mkdir $dest/webcp
cp index.js $dest/webcp/
cp package.json $dest/webcp/
cd ..

# System Software (Loader and System)
echo "----- SystemApps -----"
cd SystemApps
cargo build --release $flags
mkdir -p $dest/controller # remove this line if it's not necessary 
cp -r controller/ $dest/
cp target/release/loader $dest/
cp target/release/system $dest/
cp -r resources $dest/
cd ..

# Copy Scripts and Setup Files
echo "----- Console Files -----"
cd rqn-scripts
echo "cp console-files/* $dest/"
cp console-files/.bashrc $dest/
cp console-files/.xinitrc $dest/
cp console-files/* $dest/
cp pre-* $dest/.git/hooks/
cd ..
