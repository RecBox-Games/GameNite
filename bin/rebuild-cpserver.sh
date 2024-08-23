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


set -e

if [[ ! "$(./bin/os-name.sh)" =~ "Debian GNU/Linux 11 (bullseye)" ]]; then
    echo "Must run this script on a build machine"
    exit 0
fi

function git_clone_and_checkout() {
    local repo_name=$1
    local branch=${2-main}
    local original_dir=$(pwd)

    if [[ -d "$repo_name" ]]; then
        echo "Directory $repo_name exists. Not cloning."
    else
        git clone git@github.com:RecBox-Games/$repo_name.git
    fi

    cd "$repo_name"

    local actual_branch=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$actual_branch" != "$branch" ]]; then
	    echo "$repo_name was not on $branch. Checking out $branch"
        git checkout $branch
    fi

    cd "$original_dir"
}


## get the repos ##
git_clone_and_checkout ServerAccess
git_clone_and_checkout ControlpadServer
git_clone_and_checkout c_controlpads
git_clone_and_checkout controlpad_test_server
git_clone_and_checkout c_sharp_controlpads
git_clone_and_checkout godot-gamenite-controlpads


## ControlpadServer ##
cd ControlpadServer
cargo build --release
cp target/release/server ../controlpad_test_server/controlpad_server
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
cp target/x86_64-pc-windows-gnu/release/server.exe ../controlpad_test_server/controlpad_server.exe
exit 0
cd ..


## c_controlpads ##
cd c_controlpads
rustup default nightly
cargo build --release
rustup default stable
# copy build product to
if [[ $platform == "linux" ]]; then
    cp target/release/libc_controlpads.a ../godot-gamenite-controlpads/recbox-bin/
    cp target/release/libc_controlpads.a ../

elif [[ $platform == "windows" ]]; then
    cp target/release/c_controlpads.lib ../godot-gamenite-controlpads/recbox-bin/
fi

## godot-gamenite-controlpds
cd ../godot-gamenite-controlpads/
if [[ ! -d "./godot-cpp/bin" ]]; then
    cd godot-cpp
    git submodule update --init
    godot --dump-extension-api extension_api.json
    scons platform=$platform -j4 custom_api_file=extension_api.json
    cd ..
fi
# run scons but stop if we fail
scons platform=$platform
if [ $? -ne 0 ]; then
    echo "scons failed on the debug build. stopping"
    exit 2
fi
scons platform=$platform target=template_release

## Testing ##
# prompt if the user wants to test
read -p "Do you want to test the plugin (y/n)? " response
if [[ "$response" != "y" ]]; then
    echo "Done."
    exit 0
fi
# check that godot command exists
command -v godot
if [ $? -ne 0 ]; then
    echo "No command named godot in your path. rename you Godot executable to"
    echo "godot and put it in your path"
    exit 3
fi

# TODO: prompt the user to commit c_controlpads library to plugin repo
