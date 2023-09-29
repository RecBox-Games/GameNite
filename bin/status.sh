
status_repo() {
    start_dir=$(pwd)
    repo_path=$1
    if [[ ! -d "$repo_path" ]]; then
        echo -e "\033[0;34m$repo_path does not exist\033[0m"
        return
    fi
    cd $repo_path
    repo_name=$(basename $(git rev-parse --show-toplevel))
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    echo -e "\033[0;34m$repo_name(\033[0;36m$branch_name\033[0;34m)\033[0m"
    git -c color.status=always status | grep ":\|\[m" | sed 's/^/  /'
    if [[ ! $(git -c color.status=always status | grep ":\|\[m" | sed 's/^/  /') ]]; then
        echo "  clean"
    fi
    echo
    cd $start_dir
}


status_repo ./
status_repo rqn-scripts
status_repo ControlpadServer
status_repo SystemApps
status_repo ServerAccess
status_repo WebCP
