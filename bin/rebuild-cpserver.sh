#!/bin/bash


# TODO: check for software dependencies

## get the repos ##
git clone git@github.com:RecBox-Games/ServerAccess.git
git clone git@github.com:RecBox-Games/ControlpadServer.git
git clone git@github.com:RecBox-Games/c_controlpads.git
git clone git@github.com:RecBox-Games/controlpad_test_server.git
git clone git@github.com:RecBox-Games/c_sharp_controlpads.git
git clone git@github.com:RecBox-Games/godot-gamenite-controlpads.git
if [[ $2 != "--keep-branches" ]]; then
    # TODO: check current branches of checkouts
    cd ServerAccess; git branch main; git pull; cd ..
    cd ControlpadServer; git branch main; git pull; cd ..
    cd c_controlpads; git branch main; git pull; cd ..
    cd controlpad_test_Server; git branch main; git pull; cd ..
    cd c_sharp_controlpads; git branch main; git pull; cd ..
    cd godot-gamenite-controlpads; git branch main; git pull; cd ..
fi

set -e

## ControlpadServer ##
cd ControlpadsServer
cargo build --release
cp target/release/server ../controlpad_test_server/controlpad_server
rustup target add x86_64-pc-windows-gnu
cargo build --release --target x86_64-pc-windows-gnu
cp target/release/server ../controlpad_test_server/controlpad_server
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
