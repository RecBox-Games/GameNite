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



# Ensure four arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [--stat|--name-only|--name-status] <hash1> <hash2>"
    exit 1
fi

hash1=$2
hash2=$3


# Get the list of files that differ between the two hashes

