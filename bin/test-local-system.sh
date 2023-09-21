#!/bin/bash

grep_kill -f "rqn/system"
grep_kill -f "target/.*/system"

# run WebCP and ControlPadServer
./bin/run-server.sh $1 &

# run system apps
cd SystemApps
cargo run --bin system
