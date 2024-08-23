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

base=/home/requin/domestic/GameNite/KeyWords
dest=/home/requin/games/keywords/

echo "Bringing you to KeyWords/ts_controller..."
cd "$base/ts_controller"
echo "compiling TypeScript controller code to JavaScript"
tsc
echo "successfully compiled  TypeScript controller code to JavaScript"
echo "copying controller files to rqn/keywords..."
cp -ru "$base/controller" "$dest"
echo "successfully copied controller files to rqn/keywords"
