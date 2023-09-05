#!/bin/bash

set -e

BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

## check that we're building from the right machine ##
if [[ ! $2 == "--force-os" ]]; then
    if [[ ! "$(./bin/os-name.sh)" =~ "Debian GNU/Linux 11 (bullseye)" ]]; then
	echo "Must run this script on a build machine"
	exit 0
    fi
fi

## helper functions ##
repo_commit_string() {
    repo_name=$1
    #
    cd $repo_name
    commit=$(git rev-parse --short HEAD)
    cd ..
    #
    echo "$repo_name $commit"
}
git_clone_and_checkout() {
    repo_name=$1
    branch=${2-main}
    original_dir=$(pwd)
    if [[ -d "$repo_name" ]]; then
        echo "Directory $repo_name exists. Not cloning."
    else
        git clone git@github.com:RecBox-Games/$repo_name.git
    fi
    cd "$repo_name"
    actual_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$actual_branch" != "$branch" ]]; then
	echo "$repo_name was not on $branch. Checking out $branch"
        git checkout $branch
    fi
    cd "$original_dir"
}


## get the repos ##
git_clone_and_checkout rqn ${1-development}
git_clone_and_checkout rqn-scripts
git_clone_and_checkout ServerAccess
git_clone_and_checkout ControlpadServer
git_clone_and_checkout WebCP
git_clone_and_checkout SystemApps

## add commit hashes to rqn/.commit ##
echo "$(repo_commit_string rqn-scripts)" > rqn/.commit
echo "$(repo_commit_string ServerAccess)" >> rqn/.commit
echo "$(repo_commit_string ControlpadServer)" >> rqn/.commit
echo "$(repo_commit_string WebCP)" >> rqn/.commit
echo "$(repo_commit_string SystemApps)" >> rqn/.commit

## build rqn ##
$BIN_DIR/core_build_rqn.sh
