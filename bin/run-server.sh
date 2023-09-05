#!/bin/bash

if [ -z "$1" ]; then
    echo "needs argument for controller dir"
    exit 1
fi

function kill_process_by_name() {
    pattern=$1
    pids=$(ps aux | grep "$pattern" | grep -v grep | awk '{print $2}')
    for pid in $pids; do
        kill -9 $pid
        echo "Killed process $pid"
    done
}

kill_process_by_name "target/.*/server"
kill_process_by_name "index.js"

cd ControlpadServer
cargo run &
cd ../WebCP
git checkout main
here=$(pwd)
cd ..
cd $1
controller_dir=$(pwd)
cd $here
echo "ln -sfn $controller_dir /home/requin/controller"
ln -sfn $controller_dir /home/requin/controller
node index.js
