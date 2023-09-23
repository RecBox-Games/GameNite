#!/bin/bash

set -e

echo "Bringing you to KeyWords/ts_controller"
cd /home/requin/domestic/GameNite/KeyWords/ts_controller
echo "compiling TypeScript controller code to JavaScript..."
tsc
echo "successfully completed TypeScript controller code to JavaScript :)"
echo "copying controller files to rqn..."
cd ..
cp -ru controller/ /home/requin/rqn/games/keywords



