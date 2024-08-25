#!/bin/bash

cd $1
license-checker | grep -Ewv "MIT|Apache-2.0|ISC|BSD-[23]-Clause|CC0-1.0" | grep -B 1 "licenses:"
