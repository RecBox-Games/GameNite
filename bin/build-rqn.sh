#!/bin/bash

set -e

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"

cd $base

## check that we're building from the right machine ##
if [[ ! $2 == "--force-os" ]]; then
    if [[ ! "$($BIN_DIR/os-name.sh)" =~ "Debian GNU/Linux 11 (bullseye)" ]]; then
	echo "Must run this script on a build machine"
	exit 0
    fi
fi

## helper functions ##
repo_commit_string() {
    start_dir=$(pwd)
    repo_name=$1
    #
    if [[ "$repo_name" != "GameNite" ]]; then
        cd $repo_name
    fi
    commit=$(git rev-parse --short HEAD)
    branch=$(git rev-parse --abbrev-ref HEAD)
    cd "$start_dir"
    #
    echo "$repo_name $branch $commit"
}

git_clone_and_checkout() {
    set -e
    repo_name=$1
    branch=${2-main}
    original_dir=$(pwd)
    if [[ -d "$repo_name" ]]; then
        echo "$repo_name exists"
    else
        git clone git@github.com:RecBox-Games/$repo_name.git
    fi
    cd "$repo_name"
    git config pull.rebase false
    git fetch
    actual_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$actual_branch" != "$branch" ]]; then
	echo "$repo_name was not on $branch. Checking out $branch"
        git checkout $branch
    fi
    git pull
    cd "$original_dir"
}

set_new_version() {
    cd rqn
    # get testing version (last patch number)
    git checkout testing -- version >/dev/null
    last_patch=$(cat version)
    echo "last patch: $last_patch"
    git reset version >/dev/null
    git checkout version >/dev/null
    # check if we need to update pre-d version
    flat_patch=$(echo $last_patch | sed 's/\.//g')
    flat_version=$(cat version | sed 's/d.*//')
    if [[ $flat_patch != $flat_version ]]; then
        echo "${flat_patch}d1" > version
    else
        d_number=$(cat version | sed 's/.*d//')
        d_plus=$((d_number + 1))
        echo "${flat_version}d${d_plus}" > version
    fi
    cd ..
}

## take note of testing version (last patch number) ##

## make sure no outstanding changes in GameNite ##
if [[ -n "$(git status | grep modified)" ]]; then
    echo "There are outstanding changes in GameNite repo. Exiting."
    exit
fi

## get the repos ##
git_clone_and_checkout GameNite
git_clone_and_checkout rqn ${1-development}
git_clone_and_checkout rqn-scripts
git_clone_and_checkout ServerAccess
git_clone_and_checkout ControlpadServer
git_clone_and_checkout WebCP
git_clone_and_checkout SystemApps

## add a warning artifact if we built from the wrong OS
if [[ $2 == "--force-os" ]]; then
    touch rqn/BUILT-FROM-THE-WRONG-OS
fi

## add commit hashes to rqn/.commits ##
echo "$(repo_commit_string ./)" > rqn/.commits
echo "$(repo_commit_string rqn-scripts)" >> rqn/.commits
echo "$(repo_commit_string ServerAccess)" >> rqn/.commits
echo "$(repo_commit_string ControlpadServer)" >> rqn/.commits
echo "$(repo_commit_string WebCP)" >> rqn/.commits
echo "$(repo_commit_string SystemApps)" >> rqn/.commits

## build rqn ##
$BIN_DIR/core-build-rqn.sh

## increment the d number for version ##
set_new_version

## end message ##
cd rqn
echo "-----------------------------"
echo ""
echo "You have finished building rqn version $(cat version):"
git -c color.status=always status | grep ":\|\[m" | sed 's/\(.*\)/| \1/'
echo "-----------------------------"
echo ""
echo "Please review changed files then go into rqn and git add/commit"
