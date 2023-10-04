#!/bin/bash


BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
cd $base

if [[ -z "$1" ]]; then
  echo "Usage: $0 <number-of-lines>"
  exit 1
fi

cd rqn

if [[ "$2" != "--no-pull" ]]; then
    git reset --hard HEAD >/dev/null
    git checkout development >/dev/null
    git pull >/dev/null
    git checkout testing >/dev/null
    git pull >/dev/null
fi

NUM_LINES=$1

# Get the list of commit hashes for the testing branch
COMMIT_HASHES_TESTING=$(git rev-list -10 testing )

# find the first matching commit between development and testing
MATCHING_COMMIT=""
for commit_hash in $(git rev-list -40 development); do
    if echo "$COMMIT_HASHES_TESTING" | grep -q "$commit_hash"; then
        MATCHING_COMMIT=$commit_hash
        break
    fi
done

# Get the one line commits of the development branch up to the latest commit of testing
git checkout development &>/dev/null
DEVELOPMENT_COMMITS=$(git log -n 40 --oneline $MATCHING_COMMIT..)
NUM_DEV_LINES=$(echo "$DEVELOPMENT_COMMITS" | wc -l)

if [[ $NUM_LINES -le $NUM_DEV_LINES ]]; then
    COMMITS=$(echo "$DEVELOPMENT_COMMITS" | head -$NUM_LINES)
else
    NUM_LINES_REMAINING=$((NUM_LINES - NUM_DEV_LINES))
    # Get the one line commits of the testing branch
    git checkout testing &>/dev/null
    TESTING_COMMITS=$(git log --oneline -n $NUM_LINES_REMAINING testing)
    COMMITS=$(echo "$DEVELOPMENT_COMMITS"; echo -e "abc \033[0;34m----\033[0m" ; echo "$TESTING_COMMITS")
fi

# formatting
COMMIT_LINES=$(echo "$COMMITS" | grep -o " .*")
COLORED=$(echo "$COMMIT_LINES" | sed 's/\(release:[^:]*:\)\([^: ]*\)\( \|$\)/\1\\033[0;36m\2\\033[0m /')
echo -e "$COLORED"
