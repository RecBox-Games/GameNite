#!/bin/bash


BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
cd $base

if [[ -z "$1" ]]; then
  echo "Usage: $0 <number-of-lines>"
  exit 1
fi

cd rqn
#git fetch

NUM_LINES=$1

# Get the list of commit hashes for the testing branch
COMMITS_TESTING=$(git rev-list -10 testing )

# Find the first matching commit between development and testing
MATCHING_COMMIT=""
for commit in $(git rev-list -40 development); do
    if echo "$COMMITS_TESTING" | grep -q "$commit"; then
        MATCHING_COMMIT=$commit
        break
    fi
done

# Get the one line commits of the development branch up to the latest commit of testing
DEVELOPMENT_COMMITS=$(git log -n 40 --oneline development $MATCHING_COMMIT..)

NUM_LINES_REMAINING=$((NUM_LINES - $(echo "$DEVELOPMENT_COMMITS" | wc -l)))

# Get the one line commits of the testing branch
TESTING_COMMITS=$(git log --oneline -n $NUM_LINES_REMAINING testing)

# formatting
COMMITS=$(echo "$DEVELOPMENT_COMMITS"; echo "$TESTING_COMMITS")
COMMIT_LINES=$(echo "$COMMITS" | grep -o " .*")
COLORED=$(echo "$COMMIT_LINES" | sed 's/\(release:[^:]*:\)\([^: ]*\)\( \|$\)/\1\\033[0;36m\2\\033[0m /')
echo -e "$COLORED"
