#!/bin/bash

set -e

base=/home/requin/domestic/GameNite/KeyWords
dest=/home/requin/rqn/games/keywords/

echo "Bringing you to KeyWords/ts_controller..."
cd "$base/ts_controller"
echo "compiling TypeScript controller code to JavaScript"
tsc
echo "successfully compiled  TypeScript controller code to JavaScript"
echo "copying controller files to rqn/keywords..."
cp -ru "$base/controller" "$dest"
echo "successfully copied controller files to rqn/keywords"
