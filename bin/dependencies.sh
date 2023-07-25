#!/bin/bash

sudo apt update

# c linker and build tools
if ! command -v curl &> /dev/null; then
    sudo apt install build-essential
fi

# cross compiler to windows
if ! command -v x86_64-w64-mingw32-gcc &> /dev/null; then
    sudo apt install mingw-w64
fi

# curl
if ! command -v curl &> /dev/null; then
    sudo apt install curl
fi

# Rust
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

