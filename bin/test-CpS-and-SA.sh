#!/bin/bash

set -e

grep_kill -f "rqn/system"
grep_kill -f "cp_server"
grep_kill -f "webcp/index.js"
if [[ "$1" == "-x" ]]; then
    exit
fi

ln -sfn $(pwd)/controller /home/requin/controller
cargo build --bin system
cp -r resources target/debug/
cp target/debug/system /home/requin/rqn/
cp -r resources /home/requin/rqn/

# build and copy controlpad server
olddir=$(pwd)
cd ../ControlpadServer
cargo build
cp target/debug/server /home/requin/rqn/cp_server
cd $olddir

if [[ $1 == "--test-machine" ]]; then
    touch /home/requin/no_fullscreen
    touch /home/requin/no_1080    
fi

cargo run --bin loader

sleep 10

if [[ $1 == "--test-machine" ]]; then
    rm /home/requin/no_fullscreen
    rm /home/requin/no_1080
fi
