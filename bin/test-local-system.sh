#!/bin/bash

# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the rqn repository.
#
# The scripts in rqn are free software: you can redistribute them and/or modify
# them under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# The scripts in rqn are distributed in the hope that they will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# rqn. If not, see <https://www.gnu.org/licenses/>.


grep_kill -f "rqn/system"
grep_kill -f "target/.*/system"

# run WebCP and ControlPadServer
./bin/run-server.sh $1 &

# run system apps
cd SystemApps
cargo run --bin system
