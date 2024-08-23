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


# Define the copyright notice
read -r -d '' COPYRIGHT << EOM
# Find all .sh files in the current directory and subdirectories
find . -type f -name "*.sh" | while read -r file; do
    echo "Processing $file"
    
    # Create a temporary file
    temp_file=$(mktemp)
    
    # Preserve shebang if it exists
    if [[ $(head -n 1 "$file") == \#!* ]]; then
        head -n 1 "$file" > "$temp_file"
        echo "" >> "$temp_file"  # Add a blank line after the shebang
        tail -n +2 "$file" | sed '/^# Copyright/,/^$/d' >> "$temp_file"
    else
        sed '/^# Copyright/,/^$/d' "$file" > "$temp_file"
    fi
    
    # Add the new copyright notice
    echo "$COPYRIGHT" > "$temp_file.new"
    echo "" >> "$temp_file.new"  # Add a blank line after the copyright notice
    cat "$temp_file" >> "$temp_file.new"
    
    # Replace the original file with the new content
    mv "$temp_file.new" "$file"
    rm "$temp_file"
    
    # Make the file executable
    chmod +x "$file"
    echo "Updated copyright notice and made $file executable"
done

echo "Finished updating copyright notices and making files executable."
