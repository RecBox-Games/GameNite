# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the rqn repository.
#
# The scripts in rqn are free software: you can redistribute them and/or modify
# them under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# The scripts in rqn are distributed in the hope that they will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# rqn. If not, see <https://www.gnu.org/licenses/>.


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
