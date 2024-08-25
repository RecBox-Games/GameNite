#!/bin/bash

cd $1
cargo license --color=never | grep -vf ../bin/helper/good_licenses.txt
