#!/bin/bash

# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the GameNite repository.
#
# GameNite is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# GameNite is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# GameNite. If not, see <https://www.gnu.org/licenses/>.


set -e


prompt_user() {
    prompt=$1
    req_answer=${2-y}
    echo -n "$prompt ($req_answer/n): "
    read answer
    if [[ "$answer" != "$req_answer" ]]; then
        echo "Cancelling."
        exit 0
    fi
}

cd rqn
echo "checking out development"
git checkout development
echo "pulling silently"
git pull >/dev/null
dev_v=$(cat version)
echo "checking out testing"
git checkout testing
echo "pulling silently"
git pull >/dev/null
last_test_v=$(cat version)

# confirm that the patch was tested
echo ""
echo "-----------------------------------------------"
echo "What you are about to do is dangerous. Proceed with caution or you'll screw our users."
echo ""
prompt_user "Were all changes in $dev_v (since the last patch) reviewed?"
prompt_user "Have you tested $dev_v thoroughly?"
prompt_user "Has $dev_v been tested by someone other than yourself?" "yes"


echo "-----------------------------------------------"
echo "Development version: $dev_v"
echo "Last testing version: $last_test_v"
echo -n "The new testing version should increment the patch number or the minor "
echo "version number depending on if it is a patch or a major feature change."
echo ""
echo -n "Enter new testing version: "
read new_test_v
prompt_user "Are you sure $new_test_v is correct?"

# now that we've confirmed new version number, do the merge
export DONT_SET_THIS_MANUALLY="testing"
echo "merging development to testing branch"
set +e
git merge development --no-commit
set -e
echo "$new_test_v" > version
cat version
git add version
git status
echo "commit header: \"release:testing:$(cat version)\""
read -p "Type a helper message for the commit (or just hit ENTER): " answer
git commit -m "release:testing:$new_test_v | $answer"
git push
export DONT_SET_THIS_MANUALLY=""

# end message
echo "-----------------------------------------------"
echo "You have succesfully committed to the testing branch."
echo "Be sure to release patch notes!"
