#!/bin/bash

set -e

grep_kill -f "rqn/system"
grep_kill -f "cp_server"
grep_kill -f "target.*server"
grep_kill -f "index.js"
if [[ "$1" == "-x" ]]; then
    exit
fi

ln -sfn "$(pwd)/SystemApps/controller/controller" /home/requin/controller

cd WebCP
node index.js &

# build and copy controlpad server
cd ../ControlpadServer
cargo run &

#cp target/debug/server /home/requin/rqn/cp_server
cd ../SystemApps
cp -r resources target/debug/
cargo run --bin system

