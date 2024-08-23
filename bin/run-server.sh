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
kill_process_by_name "cp_server"
kill_process_by_name "index.js"

if [[ "$1" == "-x" ]]; then
    exit 0
fi

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
qr_ip
node index.js
