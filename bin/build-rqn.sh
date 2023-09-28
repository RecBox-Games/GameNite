#!/bin/bash

set -e

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
base="$(cd $BIN_DIR/.. && pwd)"
cd $base


## check that there is a correct branch specified ##
if [[ -z "$1" ]]; then
    echo "You have not specified a branch."
    echo "Specify a branch, probably your personal branch or development."
    echo "Exiting."
    exit
fi
rqn_branch="$1"
if [[ "$rqn_branch" == "testing" || "$rqn_branch" == "production" ]]; then
    echo "This script cannot be used to affect testing or production."
    echo "Build for a different branch, then use commit-to-testing.sh"
    echo "Exiting."
    exit
fi
if [[ "$rqn_branch" == "development" ]]; then
    echo -n "You've specified the development branch. Committing broken code to "
    echo "this branch will cause problems for others."
    read -p "Continue? [y/n] " answer
    if [[ $answer != [Yy] ]]; then
        echo "Exiting."
        exit
    fi
fi

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
    start_dir=$(pwd)
    repo_path=$1
    if [[ ! -d "$repo_path" ]]; then
        echo "$repo_path does not yet exist"
        git clone git@github.com:RecBox-Games/$repo_path.git
    fi
    cd $repo_path
    repo_name=$(basename $(git rev-parse --show-toplevel))
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo -e "\033[0;36mchecking $repo_name($branch_name)\033[0m"
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "There are outstanding changes in $repo_name repo. Fix that then try again."
        echo "Exiting."
        exit
    fi
    git fetch
    if [[ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]]; then
        echo "The $branch_name branch of $repo_name does not match origin."
        echo "push / pull then try again."
        echo "Exiting."
        exit
    fi
    if [[ "$branch_name" != "main" ]]; then
        echo "$repo_name is not on main (it's on $branch_name)."
        if [[ "$rqn_branch" == "development" ]]; then
            echo "You are building for rqn:development so checking out main."
            git checkout main
        else
            echo -n "You are not building for rqn:development so up to you. "
            read -p "Checkout main? [y/n] " answer
            if [[ $answer == [Yy]* ]]; then
                git checkout main
            fi
        fi
    fi
    git config pull.rebase false
    git pull
    cd "$start_dir"
}

set_new_version() {
    cd rqn
    # get testing version (last patch number)
    git checkout origin/testing -- version >/dev/null
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


## start message ##
this_branch=$(git rev-parse --abbrev-ref HEAD)
echo -e "\033[0;34mYou are building the $rqn_branch branch of rqn from the $this_branch branch of GameNite\033[0m"
if [[ "$this_branch" != "main" ]]; then
    echo "You should probably be on the main branch of GameNite."
    read -p "Continue anyway? [y/n]" answer
    if [[ $answer != [Yy]* ]]; then
        echo "Exiting."
        exit
    fi
fi


## get the repos ##
git_clone_and_checkout .
git_clone_and_checkout rqn-scripts
git_clone_and_checkout ServerAccess
git_clone_and_checkout ControlpadServer
git_clone_and_checkout WebCP
git_clone_and_checkout SystemApps
# TODO: separate out the above into it's own script with an option to use
# non-main branches
# msg eg: "this repo is on branch ... . checkout main?
# also checking for outstanding changes


## configure rqn branch ##
echo -e "\033[0;36mconfiguring rqn\033[0m"
if [[ ! -d "rqn" ]]; then
    echo "rqn does not yet exist"
    git clone git@github.com:RecBox-Games/rqn.git
fi
cd rqn
git fetch
# clear any local bullshit
echo "reseting rqn"
git reset --hard HEAD >/dev/null
# check that the specified branch exists
if ! git show-ref --heads --quiet "$rqn_branch"; then # check local branches
    if [[ -z $(git ls-remote --heads origin "$branch_name") ]]; then # check remote branches
        read -p "Branch $rqn_branch does not exist. Do you want to create it? [y/n] " answer
        if [[ $answer == [Yy]* ]]; then
            git checkout -b "$rqn_branch"
            git push -u origin "$rqn_branch"
        else
            "Exiting."
            exit
        fi
    else
        echo a
        git checkout $rqn_branch
    fi
else
    echo b
    git checkout $rqn_branch
fi
git config pull.rebase false
git pull
cd ..


## add commit hashes to rqn/.commits ##
echo "$(repo_commit_string GameNite)" > rqn/.commits
echo "$(repo_commit_string rqn-scripts)" >> rqn/.commits
echo "$(repo_commit_string ServerAccess)" >> rqn/.commits
echo "$(repo_commit_string ControlpadServer)" >> rqn/.commits
echo "$(repo_commit_string WebCP)" >> rqn/.commits
echo "$(repo_commit_string SystemApps)" >> rqn/.commits


## build rqn ##
$BIN_DIR/core-build-rqn.sh


## add a warning artifact if we built from the wrong OS ##
if [[ $2 == "--force-os" ]]; then
    touch rqn/BUILT-FROM-THE-WRONG-OS
fi


## increment the d number for version ##
set_new_version


## build end message ##
cd rqn
echo "-----------------------------"
echo ""
echo "You have finished building rqn version $(cat version):"
git -c color.status=always status | grep ":\|\[m" | sed 's/\(.*\)/| \1/'
echo "-----------------------------"
echo ""


## committing ##
files=$(git status --porcelain | grep ".[MAD?]" | sed 's/^...//')
# Loop through files and ask user
asnwer=""
for file in $files; do
    if [[ "$answer" != "all" ]];then
        read -p "Do you want to add $file? [y/n/all] " answer
    fi
    case $answer in
        [Yy]|all )
            git add "$file"
            echo "$file added."
            ;;
        * )
            echo "$file skipped."
            ;;
    esac
done
echo "-----------------------------"
git status
read -p "Do you want to commit? [y/n] " answer
if [[ "$answer" != "y" ]]; then
    echo "Quitting. You should probably reset local rqn changes."
    exit
fi
echo "commit header: \"release:$branch_name:$(cat version)\""
read -p "Type a helper message for the commit (or just hit ENTER): " answer
git commit -m "release:development:$(cat version) | $answer"
git push
