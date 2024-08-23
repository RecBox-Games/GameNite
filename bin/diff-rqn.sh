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

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
cd $base

# Check that there's at least 2 arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <hash1> <hash2> [--stat|--name-only|--name-status]"
    exit 1
fi

$BIN_DIR/pull.sh

echo -e "\033[0;33m(Make sure you've run \033[1;33mbin/pull.sh\033[0;33m before running this script)\033[0m"

cd rqn
git checkout testing >/dev/null

set +e
hash1="$1"
if [[ ! "$(git cat-file -t $hash1 2>/dev/null)" == "commit" ]]; then
    version_regex1=$(echo $1 | sed 's/\./\\\./g')
    log_line=$(git log --oneline testing | grep "release:.*:$version_regex1 ")
    if [[ -z "$log_line" ]]; then
        log_line=$(git log --oneline development | grep "release:.*:$version_regex1 ")
    fi
    hash1=$(echo $log_line | sed 's/ .*//')
    if [[ ! "$(git cat-file -t $hash1 2>/dev/null)" == "commit" ]]; then
        echo -e "\033[0;31m'$1' was not found to be a proper version or hash\033[0m"
        echo "Exiting"
        exit
    fi
fi

hash2="$2"
if [[ ! "$(git cat-file -t $hash2 2>/dev/null)" == "commit" ]]; then
    version_regex2=$(echo $2 | sed 's/\./\\\./g')
    log_line=$(git log --oneline testing | grep "release:.*:$version_regex2 ")
    if [[ -z "$log_line" ]]; then
        log_line=$(git log --oneline development | grep "release:.*:$version_regex2 ")
    fi
    hash2=$(echo $log_line | sed 's/ .*//')
    if [[ ! "$(git cat-file -t $hash2 2>/dev/null)" == "commit" ]]; then
        echo -e "\033[0;31m'$2' was not found to be a proper version or hash\033[0m"
        echo "Exiting"
        exit
    fi
fi
set -e


header=$(git log -n 1 --pretty=format:"%h (%an - %ar)" $hash1)
message=$(git log -n 1 --pretty=format:"%s" $hash1)
echo -e "\033[0;34mdiffing $header\033[0m"
echo "    $message"

header=$(git log -n 1 --pretty=format:"%h (%an - %ar)" $hash2)
message=$(git log -n 1 --pretty=format:"%s" $hash2)
echo -e "\033[0;34mand $header\033[0m"
echo "    $message"
echo


# Temporary files to store the .commits content
tmp1=$(mktemp)
tmp2=$(mktemp)

cd $base/rqn
# Read .commits file from both hashes and save them to temp files
git show "${hash1}:.commits" > "$tmp1"
git show "${hash2}:.commits" > "$tmp2"

# Process each repo from hash1's .commits
while IFS=' ' read -r repo branch commit1; do
    if grep -q "^$repo " "$tmp2"; then
        commit2=$(grep "^$repo " "$tmp2" | awk '{print $3}')
        echo -e "\033[0;36mdiffing $repo $commit1 $commit2\033[0m"
        if [[ "$repo" == "GameNite" ]]; then
            cd $base
        else
            cd $base/$repo
        fi
        if [[ -n "$3" ]]; then
            git diff $3 $commit1 $commit2 --
        else
            # copy files that differ from each
            $BIN_DIR/helper/diff-source-repos.sh $commit1 $commit2 $base/diff/$hash1/$repo/ $base/diff/$hash2/$repo/
        fi
    else
        echo "Warning: $repo exists in $hash1's .commits but not in $hash2's"
    fi
done < "$tmp1"

if [[ -n "$3" ]]; then
    exit
fi

# Check for repos in hash2's .commits that don't exist in hash1's
while IFS=' ' read -r repo branch commit2; do
    if ! grep -q "^$repo " "$tmp1"; then
        echo "Warning: $repo exists in $hash2's .commits but not in $hash1's"
    fi
done < "$tmp2"

# Cleanup temp files
rm "$tmp1" "$tmp2"

# run meld on em
meld "$base/diff/$hash1" "$base/diff/$hash2"
