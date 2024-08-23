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


# Ensure four arguments are provided
if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <hash1> <hash2> <output_dir1> <output_dir2>"
    exit 1
fi

hash1=$1
hash2=$2
output_dir1=$3
output_dir2=$4

# Create the output directories if they don't exist
mkdir -p "$output_dir1"
mkdir -p "$output_dir2"

# Get the list of files that differ between the two hashes
differing_files=$(git diff --name-only $hash1 $hash2)

# Loop through each file and copy it to the appropriate directory
for file in $differing_files; do
    # Copy the version of the file from hash1 to output_dir1
    dest1="${output_dir1}/${file}"
    mkdir -p "$(dirname $dest1)"
    git show "${hash1}:${file}" > "$dest1"
    
    # Copy the version of the file from hash2 to output_dir2
    dest2="${output_dir2}/${file}"
    mkdir -p "$(dirname $dest2)"
    git show "${hash2}:${file}" > "$dest2"
done

pwd # This has to be here so that the script can't fail (by having the last
    # command fail)
