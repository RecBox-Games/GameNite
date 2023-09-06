#!/bin/bash
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
git checkout development
dev_v=$(cat version)
git checkout testing
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
echo "merging development to testing branch"
git merge development
echo "$new_test_v" > version
cat version
