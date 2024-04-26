#!/bin/bash

set -e

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
dest="$base/rqn/"

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
cargo build --release
#cd controller/controller_lib
#echo "compiling TypeScript controller code to JavaScript..."
#tsc
#echo "successfully compiled TypeScript controller code to JavaScript..."
#cd ../../
mkdir -p $dest/controller # remove this line if it's not necessary 
cp -r controller/controller $dest/
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
