#!/bin/bash


# Check the first argument
platform=$1
if [[ "$platform" != "linux" && "$platform" != "windows" ]]; then
    echo "Invalid or missing argument ($platform). Expected 'linux' or 'windows'."
    exit 1
fi

# check that godot command exists
function check_for_godot {
    command -v godot
    if [ $? -ne 0 ]; then
        echo "No command named godot in your path. rename you Godot executable to"
        echo "godot and put it in your path"
        exit 3
    fi
}

# TODO: check for software dependencies

## get the repos ##
git clone git@github.com:RecBox-Games/godot-gamenite-controlpads.git
git clone git@github.com:RecBox-Games/c_controlpads.git
git clone git@github.com:RecBox-Games/ControlpadServer.git
git clone git@github.com:RecBox-Games/ServerAccess.git
if [[ $2 != "--keep-branches" ]]; then
    # TODO: check current branches of checkouts
    cd godot-gamenite-controlpads; git branch main; git pull; cd ..
    cd c_controlpads; git branch main; git pull; cd ..
    cd ControlpadServer; git branch main; git pull; cd ..
    cd ServerAccess; git branch main; git pull; cd ..
fi

set -e

## build things ##
cd c_controlpads
rustup default nightly
cargo build --release
rustup default stable
# copy build product to
if [[ $platform == "linux" ]]; then
    cp target/release/libc_controlpads.a ../godot-gamenite-controlpads/recbox-bin/

elif [[ $platform == "windows" ]]; then
    cp target/release/c_controlpads.lib ../godot-gamenite-controlpads/recbox-bin/
fi
cd ../godot-gamenite-controlpads/
if [[ ! -d "./godot-cpp/bin" ]]; then
    cd godot-cpp
    git submodule update --init
    check_for_godot
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

# copy newly created libraries into the addons directory
if [[ $platform == "linux" ]]; then
    cp demo/bin/*.so addons/gamenite-controlpads/bin/
elif [[ $platform == "windows" ]]; then
    cp demo/bin/*.dll addons/gamenite-controlpads/bin/
fi


## Testing ##
# prompt if the user wants to test
read -p "Do you want to test the plugin (y/n)? " response
if [[ "$response" != "y" ]]; then
    echo "Done."
    exit 0
fi

check_for_godot
echo "testing not yet implemented"

# TODO: prompt the user to commit c_controlpads library to plugin repo
