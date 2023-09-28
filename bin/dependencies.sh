#!/bin/bash

BIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


echo '/// Installing Packages \\\'

# update and upgrade
if [[ "$1" != "--no-upgrade" ]]; then
    echo '====== Updating Upgrading ======'
    sudo apt update
    sudo apt upgrade
    echo '================================'    
fi

# helpful function to install without wasting time if already installed
install() {
    if ! dpkg -l $1 2>/dev/null | grep . -q; then
	    if ! apt-cache search $1 | grep . -q; then
	        echo "!!! $1 package not found !!!"	>&2
	    else
	        echo ">>> Installing $1 <<<"
	        sudo apt install -y $1
	    fi
    else
	    echo "||| $1 is installed |||"
    fi
}

# c linker and build tools
install build-essential

# cross compiler to windows
install mingw-w64

# curl
install curl

# Rust
if ! command -v cargo &> /dev/null; then
    echo ">>> Installing rustup <<<"    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
else
    echo "||| rustup is installed |||" 
fi

# node
install nodejs

# nvm
source $BIN_DIR/helper/nvm-load.sh
if ! command -v nvm &> /dev/null; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi
CURRENT_NODE_VERSION=$(node -v | cut -d '.' -f 1 | tr -d 'v')
if [ "$CURRENT_NODE_VERSION" -ne 18 ]; then
    echo "Upgrading to Node.js v18..."
    nvm install 18
    nvm use 18
fi

# tsc
install node-typescript

# SystemApps dependencies
install librust-alsa-sys-dev
install librust-libudev-sys-dev

# flamegraph
install linux-tools-common

echo '\\\ Done ///'
