#!/bin/bash

# set global args
platform=$1
keep_branches=$2

function check_platform() {
    if [[ "$platform" != "linux" && "$platform" != "windows" && "$platform" != "all" &&
        "$platform" != "macos" ]]; then
        echo "Invalid or missing argument ($platform). Expected 'linux' or 'windows' or 'all'"
        echo "to compile for both platforms."
        exit 1
    fi
}

# ensure required repos are pulled
function clone_and_pull() {
    echo "======================================================================================="
    echo "$keep_branches"    
    local parent_dir=$(pwd)  # Store the current directory (folder A)
    local repos=("git@github.com:RecBox-Games/godot-gamenite-controlpads.git"
                 "git@github.com:RecBox-Games/c_controlpads.git"
                 "git@github.com:RecBox-Games/ControlpadServer.git"
                 "git@github.com:RecBox-Games/ServerAccess.git"
                )
    # clone repos if they don't exist
    for repo in "${repos[@]}"; do
        local dir=$(basename "$repo" .git)
        if [ ! -d "$dir" ]; then
            git clone "${repo}"
        fi
    done
    # get latest from main in all repos unless --keep-branches is specified
    if [[ "$keep_branches" != "--keep-branches" ]]; then
        for repo in "${repos[@]}"; do
            local dir=$(basename "$repo" .git)
            if [ -d "$dir" ] && [ -d "$dir/.git" ]; then
                echo "======================================================================================="
                cd "$dir"
                pwd
                # Change to the repository's directory, update, and return
                (                   
                    git checkout main
                    echo "pulling $dir"
                    git pull
                ) || { 
                    echo "Failed to checkout and pull in $dir"
                    pwd
                    git status
                    read -p "Do you want to restore the changes in $dir and try again? (yes/y) " clean_and_pull
                    if [[ "$clean_and_pull" == "yes" ]] || [[ "$clean_and_pull" == "y" ]]; then
                        echo "======================================================================================="
                        echo "restoring and pulling $dir"
                        git restore .
                        git pull
                    fi                    
                }
                cd ..
            fi
        done
    fi
    cd "$parent_dir"
}

# build c_controlpads in linux and copy to godot-gameniote-controlpads
function build_c_controlpads_linux() {
    cargo build --release
    cp target/release/libc_controlpads.a ../godot-gamenite-controlpads/recbox-bin/    
}

# build c_controlpads in windows and copy to godot-gameniote-controlpads
function build_c_controlpads_windows() {
    if [[ -d "target/x86_64-pc-windows-gnu/" ]]; then
        rm -rf "target/x86_64-pc-windows-gnu/"
    fi
    rustup target add x86_64-pc-windows-gnu
    cargo build --target x86_64-pc-windows-gnu --release
    mv target/x86_64-pc-windows-gnu/release/libc_controlpads.a target/x86_64-pc-windows-gnu/release/wc_controlpads.lib
    cp target/x86_64-pc-windows-gnu/release/wc_controlpads.lib ../godot-gamenite-controlpads/recbox-bin/
}

# build c_controlpads in windows and copy to godot-gameniote-controlpads
function build_c_controlpads_macos(){
    if [[ -d "target/x86_64-apple-darwin" ]]; then
       rm -rf "target/x86_64-apple-darwin"
    fi
    rustup target add x86_64-apple-darwin
    cargo build --target x86_64-apple-darwin --release
    mv target/x86_64-apple-darwin/release/libc_controlpads.a target/x86_64-apple-darwin/release/libmc_controlpads.a
    cp target/x86_64-apple-darwin/release/libmc_controlpads.a ../godot-gamenite-controlpads/recbox-bin/
}

# entry to build c_controlpads libs
function build_c_controlpads() {
    cd c_controlpads
    rustup default nightly
    # copy build product to
    if [[ $platform == "linux" ]]; then
        echo "======================================================================================="
        echo "building c_controlpads library for linux"
        echo "======================================================================================="        
        build_c_controlpads_linux

    elif [[ $platform == "windows" ]]; then
        echo "======================================================================================="
        echo "Cross compiling for windows. If you are on windows machine...be better"
        echo "jk will update the script to read or ask for the current OS you're running at some point"
        echo "======================================================================================="        
        build_c_controlpads_windows
    elif [[ $platform == "macos" ]]; then
        echo "======================================================================================="
        echo "Cross compiling for windows. If you are on windows machine...be better"
        echo "jk will update the script to read or ask for the current OS you're running at some point"
        echo "======================================================================================="        
        build_c_controlpads_macos
    fi
    rustup default stable
}

# check that godot command exists
function check_for_godot {
    command -v godot
    if [ $? -ne 0 ]; then
        echo "No command named godot in your path. rename you Godot executable to"
        echo "godot and put it in your path"
        exit 3
    fi
}

# set up godot-cpp in godot-gamenite
function build_godot_cpp() {
    cd ../godot-gamenite-controlpads/
    read -p "Did you just clone this repo or need to checkout a new branch in godot-cpp? (yes/y) " should_build_godot_cpp
    godot_version="4.1"
    if [[ "$should_build_godot_cpp" == "yes" ]] || [[ "$should_build_godot_cpp" == "y" ]]; then
        read -p "What version of godot do you want to build for? If left empty will build for godot $godot_version " input_version
        godot_version=${input_version:-$godot_version}  # Use user-provided version, or default if empty
        echo "======================================================================================="
        echo "building godot-cpp"
        echo "======================================================================================="
        cd godot-cpp
        git submodule update --init
        git pull origin "$godot_version"
        check_for_godot
        godot --dump-extension-api extension_api.json
        scons platform=$platform -j4 custom_api_file=extension_api.json
        cd ..
    fi
}

# build in root of godot-gamenite-controlpads
function build_godot_gamenite_controlpads() {
    # run scons but stop if we fail
    echo "======================================================================================="
    echo "building godot-gamenite-controlpads"
    echo "======================================================================================="
    
    scons platform=$platform
    if [ $? -ne 0 ]; then
        echo "scons failed on the debug build. stopping"
        exit 2
    fi
    scons platform=$platform target=template_release
}

function test_plugin() {
    ## Testing ##
    # prompt if the user wants to test
    read -p "Do you want to test the plugin (y/n)? " response    
    if [[ "$response" != "y" ]]; then
        echo "Done."
        exit 0
    fi
    echo "too bad"
    echo "no testing for you"
    echo "jk will implement soon"

    # TODO: prompt the user to commit c_controlpads library to plugin repo
}


############################# START HERE ################################
# 1. check platform
check_platform
# 2. ensure the repos exist
clone_and_pull
# 3. build c_controlpads
build_c_controlpads
# 4. build godot-cpp
build_godot_cpp
# 5. build godot-gamenite-controlpads
build_godot_gamenite_controlpads
# 6. test [[ NOT YET IMPLEMENTED ]]
test_plugin
#########################################################################
