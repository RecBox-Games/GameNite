#!/bin/bash

set -e

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
cd $base


# Check for exactly two arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <hash1> <hash2>"
    exit 1
fi

hash1=$1
hash2=$2

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
        # copy files that differ from each
        $BIN_DIR/helper/diff-source-repos.sh $commit1 $commit2 $base/diff/$hash1/$repo/ $base/diff/$hash2/$repo/
    else
        echo "Warning: $repo exists in $hash1's .commits but not in $hash2's"
    fi
done < "$tmp1"

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
