#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

# shellcheck disable=SC1090
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/commons.sh
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"/b-log.sh

LOG_LEVEL_WARN

main() {
  local all_git_repos_root_dir="$1"

  for git_repo_subdir in $(find "${all_git_repos_root_dir}" -type d -name ".git"); do
    local git_repo_main_dir="${git_repo_subdir%/.git}"

    pushd "${git_repo_main_dir}" || return

    eval "${WHAT}"

    popd
  done
}

main "$@"
