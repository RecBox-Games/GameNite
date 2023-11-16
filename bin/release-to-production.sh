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
echo "checking out testing"
git checkout testing
echo "pulling silently"
git pull >/dev/null
test_v=$(cat version)
echo "checking out production"
git checkout production
echo "pulling silently"
git pull >/dev/null
last_prod_v=$(cat version)

# confirm that the patch was tested
echo ""
echo "-----------------------------------------------"
echo "Proceed with caution."
echo ""
prompt_user "Has $test_v been tested by the alpha testers?" "yes"

echo "-----------------------------------------------"
echo "Testing version: $test_v"
echo "Last production version: $last_prod_v"
prompt_user "Are you sure you want to upgrade all users from $last_prod_v to $test_v?"

# do the merge
export DONT_SET_THIS_MANUALLY="production"
echo "merging testing to production branch"
set +e
git merge testing --no-commit
set -e
echo "commit header: \"release:production:$(cat version)\""
read -p "Type a helper message for the commit (or just hit ENTER): " answer
git commit -m "release:production:$test_v | $answer"
git push
export DONT_SET_THIS_MANUALLY=""

# end message
echo "-----------------------------------------------"
echo "You have succesfully committed to the production branch."
echo "Better hope you didn't mess up!"
echo "Patch notes should have been released when $test_v was committed to testing but double check"
