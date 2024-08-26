#!/bin/bash

# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the GameNite repository.
#
# GameNite is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# GameNite is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# GameNite. If not, see <https://www.gnu.org/licenses/>.


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

