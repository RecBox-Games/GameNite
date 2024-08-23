# Copyright 2022-2024 RecBox, Inc.
#
# This file is part of the rqn repository.
#
# GameNight is a free software: you can redistribute it and/or modify
# them under the terms of the GNU General Public License as published by the 
# Free Software Foundation, either version 3 of the License, or (at your option)
# any later version.
# 
# GameNight is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
# more details.
# 
# You should have received a copy of the GNU General Public License along with
# GameNight. If not, see <https://www.gnu.org/licenses/>.


pull_repo() {
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
    git pull
    echo
    cd $start_dir
}


pull_repo ./
pull_repo rqn
pull_repo rqn-scripts
pull_repo ControlpadServer
pull_repo SystemApps
pull_repo ServerAccess
pull_repo WebCP
