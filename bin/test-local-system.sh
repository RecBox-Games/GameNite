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


grep_kill -f "rqn/system"
grep_kill -f "target/.*/system"

# run WebCP and ControlPadServer
./bin/run-server.sh $1 &

# run system apps
cd SystemApps
cargo run --bin system
